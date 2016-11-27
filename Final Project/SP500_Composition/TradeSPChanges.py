import pandas as pd
import numpy as np
import sqlalchemy
from sqlalchemy import create_engine
import time
import matplotlib.pyplot as plt

CONNECTION_STRING = 'mssql+pymssql://IVYuser:resuyvi@vita.ieor.columbia.edu'

# Gets the database connection
def get_connection():
    engine = create_engine(CONNECTION_STRING)
    return engine.connect()

# Query database and return results in dataframe
def query_dataframe(query, connection=None):
    # date_col should be a list
    if connection is None:
        connection = get_connection()
    res = pd.read_sql(query, connection)
    return res

# Query database using external file and return results in dataframe
def query_dataframe_f(filename, connection=None):
    if connection is None:
        connection = get_connection()
    with open(filename, 'r') as handle:
        return pd.read_sql(handle.read(), connection)
        
# Get stock data
def get_stock_data(file_name, date_diff):
    # Get data from DB
    sql_raw = open(file_name, 'r').read()
    sql_format = sql_raw.format(date_diff = date_diff)
    data = query_dataframe(sql_format)
    # Parse data
    data.Date = pd.to_datetime(data.Date)
    data.AnnouncementDate = pd.to_datetime(data.AnnouncementDate)
    data.ChangeDate = pd.to_datetime(data.ChangeDate)
    return data
    
# Run trading strategy
# data: dataframe from get_stock_data
# log_file: Filename for log file
# strategy: 0-(Long only vs. index), 1-(Pairs only) , 2-(Pairs when available else long vs. index), 
# fixed_trade_amount: Dollar amount traded on each event
# close_offset: Close position (offset) trading days from change date
# timing: False-(Open position on open day after announcement), True-(Open position on close on announcement day)
def run_trading_strategy(data, log_file, strategy = 0, fixed_trade_amount = 10000, close_offset = 0, timing = False, t_cost = 0.0015):
    # Prepare output file
    with open(log_file, "w") as file:
        file.truncate()
    
    # Result dataframe
    results = pd.DataFrame(columns = ['DataID','AnnouncementDate','ChangeDate','LongReturn','ShortReturn','LegDiff','TransactionCost','TotalReturn'])
    
    # Run trading strategy on each component change
    for data_id, group in data.groupby('DataID'):
        # Parameters
        is_tradable = group.IsTradable.values[0]
        is_pair_tradable = group.IsPairTradable.values[0]
        announcement_date = group.AnnouncementDate.min()
        change_date = group.ChangeDate.min()
        # Entering firm
        in_name = group.In_Name.values[0]
        in_ticker = group.In_Ticker.values[0]
        in_sec_id = group.In_SecurityID.values[0]
        # Exiting firm
        out_name = group.Out_Name.values[0]
        out_ticker = group.Out_Ticker.values[0]
        out_sec_id = group.Out_SecurityID.values[0]
        
        # Check tradability
        if (is_tradable == 0):
            with open(log_file, "a") as file:
                print('\n{}-In:{}-Long leg not tradable'.format(data_id,in_name),file=file)
            continue
        if (strategy == 1 and is_pair_tradable == 0):
            with open(log_file, "a") as file:
                print('\n{}-In:{}-Out:{}-Not pair tradable'.format(data_id,in_name,out_name),file=file)
            continue
        
        # Trade dates
        # Opening trade date
        if (timing == True):
            announcement_trade_date = group[group.Date >= announcement_date]['Date'].min()
        else:
            announcement_trade_date = group[group.Date > announcement_date]['Date'].min()
        announcement_trade_date_idx = group.loc[group.Date == announcement_trade_date].index.values[0]
        # Closing trade date
        change_trade_date = group[group.Date <= change_date ]['Date'].max()
        change_trade_date_idx = group.loc[group.Date == change_trade_date].index.values[0]
        # Apply closing offset
        if (close_offset > 0):
            change_trade_date_idx = min(change_trade_date_idx + close_offset, group.index.max())
            change_trade_date = group.loc[change_trade_date_idx].Date
        elif (close_offset < 0):
            change_trade_date_idx = max(change_trade_date_idx + close_offset, announcement_trade_date_idx)
            change_trade_date = group.loc[change_trade_date_idx].Date
    
        if (strategy > 0 and is_pair_tradable == 1):
            short_ticker = out_ticker
        else:
            short_ticker = 'SPY'
        
        cumulative_transaction_cost = 0
        # Open trade
        # Short leg
        if (strategy == 0 or is_pair_tradable == 0): # Index
            if (timing == True):
                short_opening_price = group.loc[group.Date == announcement_trade_date]['IDX_ClosePrice_Adj'].values[0]
            else:
                short_opening_price = group.loc[group.Date == announcement_trade_date]['IDX_OpenPrice_Adj'].values[0]
        else: # Pairs
            if (timing == True):
                short_opening_price = group.loc[group.Date == announcement_trade_date]['Out_ClosePrice_Adj'].values[0]
            else:
                short_opening_price = group.loc[group.Date == announcement_trade_date]['Out_OpenPrice_Adj'].values[0]
        short_shares = np.floor(fixed_trade_amount / short_opening_price)
        short_opening_value = short_shares * short_opening_price
        # Long leg
        if (timing == True):
            long_opening_price = group.loc[group.Date == announcement_trade_date]['In_ClosePrice_Adj'].values[0]
        else:
            long_opening_price = group.loc[group.Date == announcement_trade_date]['In_OpenPrice_Adj'].values[0]
        long_shares = np.floor(short_opening_value / long_opening_price)
        long_opening_value = long_opening_price * long_shares
        # Leg value difference
        leg_diff = short_opening_value - long_opening_value
		# Transaction cost
        cumulative_transaction_cost += t_cost * (short_opening_value + long_opening_value)
        
        
        # Close trade
        # Short leg
        if (strategy == 0 or is_pair_tradable == 0): # Index
            short_closing_price = group.loc[group.Date == change_trade_date]['IDX_ClosePrice_Adj'].values[0]
        else: # Pairs
            short_closing_price = group.loc[group.Date == change_trade_date]['Out_ClosePrice_Adj'].values[0]
        short_closing_value = short_closing_price * short_shares
        # Long leg
        long_closing_price = group.loc[group.Date == change_trade_date]['In_ClosePrice_Adj'].values[0]
        long_closing_value = long_closing_price * long_shares
        # Transaction cost
        cumulative_transaction_cost += t_cost * (short_closing_value + long_closing_value)
        
        # Returns
        long_return = long_closing_value - long_opening_value
        short_return = short_opening_value - short_closing_value
        total_return = long_return + short_return + leg_diff - cumulative_transaction_cost
        
        # Append to df
        s = pd.Series([data_id,announcement_date,change_date,long_return,short_return,leg_diff,cumulative_transaction_cost,total_return],
                      index=['DataID','AnnouncementDate','ChangeDate','LongReturn','ShortReturn','LegDiff','TransactionCost','TotalReturn'])
        results = results.append(s, ignore_index=True)
        
        with open(log_file, "a") as file:
            print('\n{}-In:{}-{} - Out:{}-{}- A-Date: {} - C-Date: {}\n'
                  '{}'
                  '\nLong Leg - Buy   : {} shares of {} @ {:.2f} for {:.2f}'
                  '\nShort Leg - Sell : {} shares of {} @ {:.2f} for {:.2f}'
                  '\nLeg value difference:{:.2f}'
                  '\nTransaction costs:{:.2f}'
                  '\n{}'
                  '\nLong Leg - Sell   : {} shares of {} @ {:.2f} for {:.2f}'
                  '\nShort Leg - Buy : {} shares of {} @ {:.2f} for {:.2f}'
                  '\nTransaction costs:{:.2f}'
                  '\nResults'
                  '\nReturn on Long: {:.2f}, Return on Short: {:.2f}'
                  '\nTotal Return: {:.2f}\n'
                  .format(data_id,
                          in_name,
                          in_sec_id,
                          out_name,
                          out_sec_id,
                          pd.to_datetime(announcement_date).strftime('%Y-%m-%d'),
                          pd.to_datetime(change_date).strftime('%Y-%m-%d'),
                          pd.to_datetime(announcement_trade_date).strftime('%Y-%m-%d'),
                          long_shares,
                          in_ticker,
                          long_opening_price,
                          long_opening_value,
                          short_shares,
                          short_ticker,
                          short_opening_price,
                          short_opening_value,
                          leg_diff,
                          t_cost * (short_opening_value + long_opening_value),
                          pd.to_datetime(change_trade_date).strftime('%Y-%m-%d'),
                          long_shares,
                          in_ticker,
                          long_closing_price,
                          long_closing_value,
                          short_shares,
                          short_ticker,
                          short_closing_price,
                          short_closing_value,
                          t_cost * (short_closing_value + long_closing_value),
                          long_return,
                          short_return,
                          total_return)
                  ,file=file)
    results['CumDollarReturn'] = results.TotalReturn.cumsum()
    
    print('Trades: {} - Winning: {} - Losing: {}'.format(
        len(results), len(results[results.TotalReturn>=0]), len(results[results.TotalReturn<0])))
    print('Long  Leg Returns - Mean: {:.2f} - Stdev: {:.2f} - Max: {:.2f} - Min: {:.2f}'.format(
        results.LongReturn.mean(), results.LongReturn.std(), results.LongReturn.max(), results.LongReturn.min()))
    print('Short Leg Returns - Mean: {:.2f} - Stdev: {:.2f} - Max: {:.2f} - Min: {:.2f}'.format(
        results.ShortReturn.mean(), results.ShortReturn.std(), results.ShortReturn.max(), results.ShortReturn.min()))
    print('Total Returns:    - Mean: {:.2f} - Stdev: {:.2f} - Max: {:.2f} - Min: {:.2f}'.format(
        results.TotalReturn.mean(), results.TotalReturn.std(), results.TotalReturn.max(), results.TotalReturn.min()))
    print('Cumulative Returns: {:.2f} - Cumulative Transaction costs: {:.2f}'.format(
        results.CumDollarReturn[-1:].values[0], results.TransactionCost.sum()))        
    
    fig, ax = plt.subplots(figsize=(18,5))
    plt.hist(results.TotalReturn,100)
    plt.title('Trade returns')
    plt.xlabel('Dollar return')
    plt.ylabel('Frequency')
    plt.show()
    fig, ax = plt.subplots(figsize=(18,5))
    plt.plot(results.ChangeDate, results.CumDollarReturn,'k')
    plt.plot(results[results.TotalReturn>0].ChangeDate, results[results.TotalReturn>0].CumDollarReturn,'g.')
    plt.plot(results[results.TotalReturn<0].ChangeDate, results[results.TotalReturn<0].CumDollarReturn,'r.')
    plt.title('Cumulative Returns ($)')
    plt.ylabel('$')
    plt.show()
    
    results.to_csv(log_file,index=None,sep=',',mode='a')
    return results
import pandas as pd
import numpy as np
import seaborn as sns
import sqlalchemy
from sqlalchemy import create_engine
import time
import matplotlib.pyplot as plt
from matplotlib.finance import candlestick_ohlc
from matplotlib.dates import date2num
from matplotlib.dates import DateFormatter,WeekdayLocator,DayLocator,MONDAY

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
	
# Plot data
def plot_data(data,version=0):
	for data_id, group in data.groupby('DataID'):
		announcement_date = group.AnnouncementDate.values[0]
		announcement_date_str = pd.to_datetime(announcement_date).strftime('%Y-%m-%d')
		change_date = group.ChangeDate.values[0]
		change_date_str = pd.to_datetime(change_date).strftime('%Y-%m-%d')
		in_name = group.In_Name.values[0]
		in_ticker = group.In_Ticker.values[0]
		in_sec_id = group.In_SecurityID.values[0]
		out_name = group.Out_Name.values[0]
		out_ticker = group.Out_Ticker.values[0]
		out_sec_id = group.Out_SecurityID.values[0]
		is_tradable = group.IsTradable.values[0]
		is_pair_tradable = group.IsPairTradable.values[0]
		is_takeover = group.IsTakeover.values[0]
		
		print('{} - In:{} - Out:{}\nAnnouncement:{} - Change:{}\nTakeover:{} - Tradable:{} - PairTradable:{}'.format(data_id,in_name,out_name,announcement_date_str,change_date_str,is_takeover,is_tradable,is_pair_tradable))
		
		if(version == 0):
			fig, (ax1, ax3) = plt.subplots(2, 1, figsize=(18,10))
			ax2 = ax1.twinx()
			ax4 = ax3.twinx()
			
			ax1.plot(group.Date, group.In_ClosePrice_Adj,'b-o')
			ax2.plot(group.Date, group.Out_ClosePrice_Adj,'r-o')
			ax3.plot(group.Date, group.In_Volume, 'b.-')
			ax4.plot(group.Date, group.Out_Volume, 'r.-')
			
			ax1.legend([in_ticker],loc=2),ax2.legend([out_ticker],loc=1),
			ax3.legend([in_ticker],loc=2),ax4.legend([out_ticker],loc=1)
			
			ax1.axvline(x=announcement_date,color='g',ls='dashed')
			ax1.axvline(x=change_date,color='k',ls='dashed')
			ax3.axvline(x=announcement_date,color='g',ls='dashed')
			ax3.axvline(x=change_date,color='k',ls='dashed')
			
			ax1.grid(True), ax3.grid(True)
			ax1.set_title('Stock Prices - In:Blue - Out:Red')
			ax3.set_title('Volume - In:Blue - Out:Red')
			plt.ylabel('Volume')
			plt.show()
			
		elif(version == 1):
			fig, (ax1, ax3, ax5, ax7) = plt.subplots(4, 1, figsize=(18,20))
			ax2 = ax1.twinx()
			ax4 = ax3.twinx()
			ax6 = ax5.twinx()
			ax8 = ax7.twinx()
			
			ax1.plot(group.Date, group.In_ClosePrice_Adj,'b-o')
			ax2.plot(group.Date, group.Out_ClosePrice_Adj,'r-o')
			ax3.plot(group.Date, group.In_Volume, 'b.-')
			ax4.plot(group.Date, group.Out_Volume, 'r.-')
			ax5.plot(group.Date, group.In_Call_OI, 'b.-')
			ax5.plot(group.Date, group.In_Put_OI, 'b.--')
			ax6.plot(group.Date, group.Out_Call_OI, 'r.-')
			ax6.plot(group.Date, group.Out_Put_OI, 'r.--')
			ax7.plot(group.Date, group.In_Call_Volume, 'b.-')
			ax7.plot(group.Date, group.In_Put_Volume, 'b.--')
			ax8.plot(group.Date, group.Out_Call_Volume, 'r.-')
			ax8.plot(group.Date, group.Out_Put_Volume, 'r.--')
			
			ax1.legend([in_ticker],loc=2),ax2.legend([out_ticker],loc=1)
			ax3.legend([in_ticker],loc=2),ax4.legend([out_ticker],loc=1)
			ax5.legend(['C','P'],loc=2),ax6.legend(['C','P'],loc=1)
			ax7.legend(['C','P'],loc=2),ax8.legend(['C','P'],loc=1)
			
			ax1.axvline(x=announcement_date,color='g',ls='dashed')
			ax1.axvline(x=change_date,color='k',ls='dashed')
			ax3.axvline(x=announcement_date,color='g',ls='dashed')
			ax3.axvline(x=change_date,color='k',ls='dashed')
			ax5.axvline(x=announcement_date,color='g',ls='dashed')
			ax5.axvline(x=change_date,color='k',ls='dashed')
			ax7.axvline(x=announcement_date,color='g',ls='dashed')
			ax7.axvline(x=change_date,color='k',ls='dashed')
			
			ax1.grid(True), ax3.grid(True), ax4.grid(True), ax7.grid(True)
			ax1.set_title('Stock Prices - In:Blue - Out:Red')
			ax3.set_title('Volume - In:Blue - Out:Red')
			ax5.set_title('Option Open Interest - In:Blue - Out:Red')
			ax7.set_title('Option Volume - In:Blue - Out:Red')
			plt.show()

select 
convert(datetime, [The Date for this Price Record]) as Date,
[Security ID] as SecurityID, 
[Ticker Symbol] as Ticker,
[Index Flag] as IndexFlag,
[Exchange Designator] as ExchangeDesignator,
[Class Designator] as ClassDesignator,
[The Type of Security] as SecurityType,
[Low (or Closing Bid if Negative)] as PriceLow,
[High (or Closing Ask if Negative)] as PriceHigh,
[Open Price (0 if no opening price)] as PriceOpen,
[Close (or Bid-Ask Average if Negative)] as PriceClose,
Volume, 
[Return Since Last Good Pricing Date] as TotalReturn,
[Cumulative Adjustment Factor] as AdjustmentFactor,
[Shares Outstanding] as SharesOutstanding,
[Cumulative Total Return Factor] as CumulativeTotalReturn
into XF.db_datawriter.hi2179_SP500_comp_2_data
from XF.db_datawriter.in_Aug2013_Apr2016


insert into XF.db_datawriter.hi2179_SP500_comp_2_data
select 
convert(datetime, [The Date for this Price Record]) as Date,
[Security ID] as SecurityID, 
[Ticker Symbol] as Ticker,
[Index Flag] as IndexFlag,
[Exchange Designator] as ExchangeDesignator,
[Class Designator] as ClassDesignator,
[The Type of Security] as SecurityType,
[Low (or Closing Bid if Negative)] as PriceLow,
[High (or Closing Ask if Negative)] as PriceHigh,
[Open Price (0 if no opening price)] as PriceOpen,
[Close (or Bid-Ask Average if Negative)] as PriceClose,
Volume, 
[Return Since Last Good Pricing Date] as TotalReturn,
[Cumulative Adjustment Factor] as AdjustmentFactor,
[Shares Outstanding] as SharesOutstanding,
[Cumulative Total Return Factor] as CumulativeTotalReturn
from XF.db_datawriter.out_Aug2013_Apr2016


create table XF.db_datawriter.hi2179_SP500_comp_2_SecData
(
Date datetime,
SecurityID int,
Ticker varchar(500),
IndexFlag int,
ExchangeDesignator int,
ClassDesignator varchar(50),
SecurityType varchar(50),
PriceLow float,
PriceHigh float,
PriceOpen float,
PriceClose float,
Volume bigint,
TotalReturn float,
AdjustmentFactor float,
SharesOutstanding bigint,
CumulativeTotalReturn float
)



insert into XF.db_datawriter.hi2179_SP500_comp_2_SecData
select 
Date,
SecurityID, 
Ticker,
IndexFlag,
ExchangeDesignator,
ClassDesignator,
SecurityType,
convert(float,PriceLow),
convert(float,PriceHigh),
convert(float,PriceOpen),
convert(float,PriceClose),
convert(bigint,Volume), 
convert(float,TotalReturn),
convert(float,AdjustmentFactor),
convert(bigint,SharesOutstanding),
convert(float,CumulativeTotalReturn)
from XF.db_datawriter.hi2179_SP500_comp_2_data



insert into XF.db_datawriter.hi2179_SP500_comp_2_SecData
select 
convert(date,date),
secid, 
Ticker,
index_flag,
exchange_d,
class,
issue_type,
convert(float,low),
convert(float,high),
convert(float,[open]),
convert(float,[close]),
convert(bigint,Volume), 
convert(float,[return]),
convert(float,cfadj),
convert(bigint,shrout),
convert(float,cfret)
from db_datawriter.hi2179_in_out_new_tickers
where secid in (134645)
order by date, secid


insert into XF.db_datawriter.hi2179_SP500_comp_2_SecData
select 
convert(date,date),
secid, 
Ticker,
index_flag,
exchange_d,
class,
issue_type,
convert(float,low),
convert(float,high),
convert(float,[open]),
convert(float,[close]),
convert(bigint,Volume), 
convert(float,[return]),
convert(float,cfadj),
convert(bigint,shrout),
convert(float,cfret)
from db_datawriter.hi2179_09a4aa2420f9b2f2
where secid not in (select distinct securityID from XF.db_datawriter.hi2179_SP500_comp_2_SecData)
order by date, secid






insert into XF.db_datawriter.hi2179_SP500_comp_2_SecData
select 
convert(date,date),
secid, 
Ticker,
index_flag,
exchange_d,
class,
issue_type,
convert(float,low),
convert(float,high),
convert(float,[open]),
convert(float,[close]),
convert(bigint,Volume), 
convert(float,[return]),
convert(float,cfadj),
convert(bigint,shrout),
convert(float,cfret)
from db_datawriter.hi2179_d9e3ee1fa50befe0
where secid in (108105,109820)
order by date, secid







select *
from XF.db_datawriter.hi2179_SP500_comp_2_SecData
where SecurityID in (207008,134645)
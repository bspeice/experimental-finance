/*
AAPL 2013-10-28
TSLA 2013-11-05
GOOG 2013-10-17
*/
/*
symbol	timestamp	expiration	strike	optiontype	tradesize	tradePrice	tradeConditionID	canceledTradeConditionID
AAPL	2013-10-09 12:32:04.7500000	2013-11-16 00:00:00.000	530.00000	c	5000	5.40000	13	0
AAPL	2013-10-10 14:23:27.2500000	2013-11-16 00:00:00.000	500.00000	c	4500	14.30000	106	0
AAPL	2013-10-10 15:26:42.4250000	2013-10-11 00:00:00.000	500.00000	c	3021	0.11000	18	0
AAPL	2013-10-09 12:31:29.8500000	2013-11-16 00:00:00.000	505.00000	c	2500	11.10000	13	0
AAPL	2013-10-18 12:24:54.8500000	2013-11-16 00:00:00.000	525.00000	c	2350	9.25000	35	1
AAPL	2013-10-18 14:12:56.9500000	2013-11-16 00:00:00.000	525.00000	c	2350	9.35000	35	0
AAPL	2013-10-18 14:17:43.4000000	2013-11-16 00:00:00.000	525.00000	c	2350	9.25000	35	2
AAPL	2013-10-10 14:23:17.3250000	2013-10-19 00:00:00.000	450.00000	c	2275	39.10000	106	0
AAPL	2013-10-15 10:33:15.1250000	2013-11-16 00:00:00.000	445.00000	p	2160	2.42000	38	0
AAPL	2013-10-07 10:40:16.4750000	2013-11-16 00:00:00.000	415.00000	p	2100	1.31000	106	0
*/

-- Get minute-by-minute data for options
select symbol, [timestamp], expiration, strike, optiontype, [open], high, low, [close], tradevolume
into #data_calc
from XFDATA.dbo.lv_minute_options_calcs
where symbol = 'GOOG'
and (timestamp < '2013-10-10' or timestamp > '2013-10-24')
and tradeVolume > 0

-- Get tick data for stock
select symbol, [timestamp], expiration, strike, optiontype, tradesize, tradePrice, tradeConditionID, canceledTradeConditionID
into #data_trade
from XFDATA.dbo.lv_options_trades
where symbol = 'GOOG'
and (timestamp < '2013-10-10' or timestamp > '2013-10-24')
and tradeSize > 0


-- Find largest trades
select top 100 *
from #data_calc
order by tradeVolume desc

select top 100 *
from #data_trade
order by tradeSize desc



-- Examine large trade
select symbol, [timestamp], expiration, strike, [open], high, low, [close], tradeVolume, bidsize, bestbid, asksize, bestask, impliedUndPrice, activeUndPrice, iv, delta,
datediff(day,convert(date,[timestamp]),expiration) as ExpD
from XFDATA.dbo.lv_minute_options_calcs
where symbol = 'GOOG'
and timestamp between '2013-10-25 11:30' and '2013-10-25 12:30'
and optionType = 'p'
and [close] > 0
and strike = 1015
order by expiration, timestamp


select symbol, [timestamp], expiration, strike, optiontype, tradesize, tradePrice, tradeConditionID, canceledTradeConditionID
from XFDATA.dbo.lv_options_trades
where symbol = 'GOOG'
and timestamp between '2013-10-25 11:30' and '2013-10-25 12:30'
and optionType = 'c'
order by expiration, timestamp





drop table #data_calc, #data_trade
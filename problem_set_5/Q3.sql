declare @EarningsDate datetime = '2013-10-28'

--select *
--from XFDATA.dbo.lv_options_trades
--where symbol = 'AAPL'
--and datediff(dd,timestamp, @EarningsDate) > 7

select top 10 *
from XFDATA.dbo.lv_minute_options_calcs
where symbol = 'AAPL'
and datediff(dd,timestamp, @EarningsDate) > 7
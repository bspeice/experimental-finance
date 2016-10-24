declare @Ticker varchar(10) = 'KKD'
declare @SecurityID int = (select SecurityID from XFDATA.dbo.SECURITY where ticker = @Ticker)
declare @StartDate datetime = '2003-1-1'
declare @EndDate datetime = '2006-12-31'

select Date, XF.dbo.formatStrike(Strike) as Strike, Expiration, datediff(day,Date,Expiration) as ExpirationD,
CallPut, XF.dbo.mbbo(BestBid,BestOffer) as MBBO, ImpliedVolatility,
XF.db_datawriter.InterpolateRate(datediff(day,Date,Expiration), Date)/100.0 as Rate
into #data
from XFDATA.dbo.OPTION_PRICE_VIEW
where SecurityID = @SecurityID
and Date between @StartDate and @EndDate


select * 
from #data d
where Date in (select min(Date) from #data group by year(Date), month(Date))
and ImpliedVolatility > 0



drop table #data
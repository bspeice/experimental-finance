-- Parameters are set externally
declare @Ticker varchar(10) = '{ticker}'
declare @SecurityID int = (select SecurityID from XFDATA.dbo.SECURITY where Ticker = @Ticker)
declare @DateStart datetime = '{date_start}'  -- yyyy-MM-dd
declare @DateEnd datetime = '{date_end}'      -- yyyy-MM-dd

select Date, Expiration
into #Expirations
from XFDATA.dbo.OPTION_PRICE_VIEW
where SecurityID = @SecurityID and Date between @DateStart and @DateEnd

update e set
  [First] = (select min(Expiration) from #Expirations where Date=cast(e.EarningDate as date) and Expiration > cast(e.EarningDate as date)),
  [Second] = (select min(Expiration) from #Expirations where Date=cast(e.EarningDate as date) and Expiration > cast(e.EarningDate as date)
                                                             and Expiration > (select min(Expiration)
                        from #Expirations where Date=cast(e.EarningDate as date) and Expiration > cast(e.EarningDate as date))),
  [JanLeap] = (select min(Expiration) from #Expirations where Date=cast(e.EarningDate as date)
                and Expiration > cast(e.EarningDate as date)
                and datediff(month,e.EarningDate,Expiration) > 5 and month(Expiration) = 1)
from Earnings e

select * from Earnings


drop table #Expirations, Earnings

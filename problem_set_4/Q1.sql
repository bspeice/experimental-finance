-- KO 103125

select 
  op.Date as DateO,
  sp.Date as DateS,
  op.SecurityID,
  XF.dbo.formatStrike(op.Strike)                      AS Strike,
  op.Expiration,
  op.CallPut,
  XF.dbo.mbbo(op.BestBid, op.BestOffer)               AS MBBO,
  op.ImpliedVolatility,
  op.Volume,
  op.OpenInterest,
  sp.ClosePrice,
  abs(sp.ClosePrice - XF.dbo.formatStrike(op.Strike)) AS StrikeDiff
into #Coke
from XFDATA.dbo.OPTION_PRICE_VIEW op
  inner join XFDATA.dbo.SECURITY_PRICE sp on 
    sp.SecurityID = op.SecurityID 
	and datediff(day, op.Date, sp.Date) <= case when datediff(day,op.Date,op.Expiration)<=1 then 15 else 0 end
	and datediff(day, op.Date, sp.Date) >= 0
where op.SecurityID = 103125
  and op.Date between '2013-1-1' and '2013-12-31'

select * from #Coke
order by Expiration, DateO, DateS

--select distinct Date, ClosePrice, Expiration, Strike, StrikeDiff, 
--  case when StrikeDiff < 0.15 then 1 else 0 end as Pin,
--  datediff(day, Expiration, Date) as T
--from #Coke c
--where StrikeDiff = (select min(StrikeDiff) from #Coke cc where c.Date = cc.Date)
--order by Expiration, Date

--SELECT
--  DATEPART(WEEKDAY, Expiration),
--  count(*)
--FROM #Coke
--GROUP BY DATEPART(WEEKDAY, Expiration)

--drop table #Coke
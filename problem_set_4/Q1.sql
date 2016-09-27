-- KO 103125

select op.Date, op.SecurityID, XF.dbo.formatStrike(op.Strike) as Strike, op.Expiration, op.CallPut, XF.dbo.mbbo(op.BestBid, op.BestOffer) as MBBO,
  op.ImpliedVolatility, op.Volume, op.OpenInterest, sp.ClosePrice, abs(sp.ClosePrice - XF.dbo.formatStrike(op.Strike)) as StrikeDiff
into #Coke
from XFDATA.dbo.OPTION_PRICE_VIEW op
inner join XFDATA.dbo.SECURITY_PRICE sp on sp.Date = op.Date and sp.SecurityID = op.SecurityID
where op.SecurityID = 103125



select *
from #Coke






select distinct Expiration
from #Coke
order by 1

select  DATEPART ( weekday , Expiration ), count(*)
from #Coke
group by DATEPART ( weekday , Expiration )

drop table #Coke
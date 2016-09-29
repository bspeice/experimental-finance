-- CSCO 103042
declare @SecurityID int = 103042
declare @WeekStart datetime = '2007-1-8' 
declare @WeekEnd datetime = '2007-1-12'
declare @OptionType char = 'P'
declare @TargetFactor float = 1

-- Get all relevant data
select op.Date, sp.ClosePrice as StockPrice, 
  op.CallPut, op.Expiration, datediff(day,op.Date,Expiration) as DaysToMaturity, 
  XF.dbo.formatStrike(op.Strike) as Strike, op.ImpliedVolatility, XF.dbo.mbbo(op.BestBid,op.BestOffer) as MBBO, 
  round(@TargetFactor * sp.ClosePrice,2) as StrikePriceTarget, (XF.dbo.formatStrike(op.Strike)-@TargetFactor * sp.ClosePrice) as TargetDistance
into #data
from XFDATA.dbo.OPTION_PRICE_VIEW op
  inner join XFDATA.dbo.SECURITY_PRICE sp on sp.SecurityID = op.SecurityID and sp.Date = op.Date
where op.SecurityID = @SecurityID
  and op.Date between @WeekStart and @WeekEnd
  and op.CallPut = @OptionType

-- Code:  HS: High Strike, LS: Low Strike, BM: Before Maturity, AM: After Maturity
select *
into #HS_BM
from #data d1
where abs(DaysToMaturity - 45) = (
  select min(abs(DaysToMaturity - 45))
  from #data d2
  where d1.Date = d2.Date
    and DaysToMaturity <= 45
)
and TargetDistance >= 0
order by Date

select *
into #HS_AM
from #data d1
where abs(DaysToMaturity - 45) = (
  select min(abs(DaysToMaturity - 45))
  from #data d2
  where d1.Date = d2.Date
    and DaysToMaturity >= 45
)
and TargetDistance >= 0
order by Date

select *
into #LS_BM
from #data d1
where abs(DaysToMaturity - 45) = (
  select min(abs(DaysToMaturity - 45))
  from #data d2
  where d1.Date = d2.Date
    and DaysToMaturity <= 45
)
and TargetDistance <= 0
order by Date

select *
into #LS_AM
from #data d1
where abs(DaysToMaturity - 45) = (
  select min(abs(DaysToMaturity - 45))
  from #data d2
  where d1.Date = d2.Date
    and DaysToMaturity >= 45
)
and TargetDistance <= 0
order by Date

-- Select 4 options having....
select *, 'HS-BM' as Code
from #HS_BM d1
where TargetDistance = (
  select min(TargetDistance)
  from #HS_BM d2
  where d1.Date = d2.Date
)
union
select *, 'HS-AM' as Code
from #HS_AM d1
where TargetDistance = (
  select min(TargetDistance)
  from #HS_AM d2
  where d1.Date = d2.Date
)
union
select *, 'LS-BM' as Code
from #LS_BM d1
where TargetDistance = (
  select max(TargetDistance)
  from #LS_BM d2
  where d1.Date = d2.Date
)
union
select *, 'LS-AM' as Code
from #LS_AM d1
where TargetDistance = (
  select max(TargetDistance)
  from #LS_AM d2
  where d1.Date = d2.Date
)

drop table #data, #HS_AM, #HS_BM, #LS_AM, #LS_BM
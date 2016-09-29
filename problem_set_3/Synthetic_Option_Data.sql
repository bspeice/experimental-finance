-- TODO: description 

-- Parameters are set using Python
declare @Ticker varchar(10) = '{ticker}'
declare @DateStart datetime = '{date_start}' 
declare @DateEnd datetime = '{date_end}'
declare @OptionType char = '{opt_type}'
declare @TargetMaturityDays int = '{target_maturity}'
declare @TargetFactor float = '{target_factor}'

-- Get all relevant data
select op.Date, sp.ClosePrice as StockPrice, 
  op.CallPut, op.Expiration, datediff(day,op.Date,Expiration) as DaysToMaturity, 
  XF.dbo.formatStrike(op.Strike) as Strike, op.ImpliedVolatility, XF.dbo.mbbo(op.BestBid,op.BestOffer) as MBBO, 
  round(convert(float,@TargetFactor) * sp.ClosePrice,2) as StrikePriceTarget, (XF.dbo.formatStrike(op.Strike)-@TargetFactor * sp.ClosePrice) as TargetDistance,
  XF.[db_datawriter].InterpolateRate(@TargetMaturityDays, op.Date) as ZeroRate
into #data
from XFDATA.dbo.OPTION_PRICE_VIEW op
  inner join XFDATA.dbo.SECURITY_PRICE sp on sp.SecurityID = op.SecurityID and sp.Date = op.Date
  inner join XFDATA.dbo.SECURITY s on s.SecurityID = sp.SecurityID
where s.Ticker = @Ticker
  and op.Date between @DateStart and @DateEnd
  and op.CallPut = @OptionType

-- Higher strike, shorter maturity
select *
into #HS_BM
from #data d1
where abs(DaysToMaturity - @TargetMaturityDays) = (
  select min(abs(DaysToMaturity - @TargetMaturityDays))
  from #data d2
  where d1.Date = d2.Date
    and DaysToMaturity <= @TargetMaturityDays
)
and TargetDistance >= 0
and DaysToMaturity <= @TargetMaturityDays
order by Date

-- Higher strike, longer maturity
select *
into #HS_AM
from #data d1
where abs(DaysToMaturity - @TargetMaturityDays) = (
  select min(abs(DaysToMaturity - @TargetMaturityDays))
  from #data d2
  where d1.Date = d2.Date
    and DaysToMaturity >= @TargetMaturityDays
)
and TargetDistance >= 0
and DaysToMaturity >= @TargetMaturityDays
order by Date

-- Lower strike, shorter maturity
select *
into #LS_BM
from #data d1
where abs(DaysToMaturity - @TargetMaturityDays) = (
  select min(abs(DaysToMaturity - @TargetMaturityDays))
  from #data d2
  where d1.Date = d2.Date
    and DaysToMaturity <= @TargetMaturityDays
)
and TargetDistance <= 0
and DaysToMaturity <= @TargetMaturityDays
order by Date

-- Lower strike, longer maturity
select *
into #LS_AM
from #data d1
where abs(DaysToMaturity - @TargetMaturityDays) = (
  select min(abs(DaysToMaturity - @TargetMaturityDays))
  from #data d2
  where d1.Date = d2.Date
    and DaysToMaturity >= @TargetMaturityDays
)
and TargetDistance <= 0
and DaysToMaturity >= @TargetMaturityDays
order by Date

-- Combine data
select *, case when d1.TargetDistance = 0 then 'ON-BM' else case when d1.DaysToMaturity = @TargetMaturityDays then 'HS-ON' else 'HS-BM' end end as Code
from #HS_BM d1
where TargetDistance = (
  select min(TargetDistance)
  from #HS_BM d2
  where d1.Date = d2.Date
)
union
select *, case when d1.TargetDistance = 0 then 'ON-AM' else case when d1.DaysToMaturity = @TargetMaturityDays then 'HS-ON' else 'HS-AM' end end as Code
from #HS_AM d1
where TargetDistance = (
  select min(TargetDistance)
  from #HS_AM d2
  where d1.Date = d2.Date
)
union
select *, case when d1.TargetDistance = 0 then 'ON-BM' else case when d1.DaysToMaturity = @TargetMaturityDays then 'LS-ON' else 'LS-BM' end end as Code
from #LS_BM d1
where TargetDistance = (
  select max(TargetDistance)
  from #LS_BM d2
  where d1.Date = d2.Date
)
union
select *, case when d1.TargetDistance = 0 then 'ON-AM' else case when d1.DaysToMaturity = @TargetMaturityDays then 'LS-ON' else 'LS-AM' end end as Code
from #LS_AM d1
where TargetDistance = (
  select max(TargetDistance)
  from #LS_AM d2
  where d1.Date = d2.Date
)
order by Date

drop table #data, #HS_AM, #HS_BM, #LS_AM, #LS_BM

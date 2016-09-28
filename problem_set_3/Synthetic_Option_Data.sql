-- TODO: description 

-- Parameters are set using Python
DECLARE @Ticker VARCHAR(10) = '{ticker}'
DECLARE @DateStart DATETIME = '{date_start}'
DECLARE @DateEnd DATETIME = '{date_end}'
DECLARE @OptionType CHAR = '{opt_type}'
DECLARE @TargetMaturityDays INT = '{target_maturity}'
DECLARE @TargetFactor FLOAT = '{target_factor}'

-- Get all relevant data
SELECT
  op.Date,
  sp.ClosePrice                                                    AS StockPrice,
  op.CallPut,
  op.Expiration,
  datediff(DAY, op.Date, Expiration)                               AS DaysToMaturity,
  XF.dbo.formatStrike(op.Strike)                                   AS Strike,
  op.ImpliedVolatility,
  XF.dbo.mbbo(op.BestBid, op.BestOffer)                            AS MBBO,
  round(convert(FLOAT, @TargetFactor) * sp.ClosePrice, 2)          AS StrikePriceTarget,
  (XF.dbo.formatStrike(op.Strike) - @TargetFactor * sp.ClosePrice) AS TargetDistance,
  XF.[db_datawriter].InterpolateRate(@TargetMaturityDays, op.Date) AS ZeroRate
INTO #data
FROM XFDATA.dbo.OPTION_PRICE_VIEW op
  INNER JOIN XFDATA.dbo.SECURITY_PRICE sp ON sp.SecurityID = op.SecurityID AND sp.Date = op.Date
  INNER JOIN XFDATA.dbo.SECURITY s ON s.SecurityID = sp.SecurityID
WHERE s.Ticker = @Ticker
      AND op.Date BETWEEN @DateStart AND @DateEnd
      AND op.CallPut = @OptionType

-- Higher strike, shorter maturity
<<<<<<< HEAD
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
=======
SELECT *
INTO #HS_BM
FROM #data d1
WHERE abs(DaysToMaturity - @TargetMaturityDays) = (
  SELECT min(abs(DaysToMaturity - @TargetMaturityDays))
  FROM #data d2
  WHERE d1.Date = d2.Date
        AND DaysToMaturity < @TargetMaturityDays
)
      AND TargetDistance >= 0
ORDER BY Date

-- Higher strike, longer maturity
SELECT *
INTO #HS_AM
FROM #data d1
WHERE abs(DaysToMaturity - @TargetMaturityDays) = (
  SELECT min(abs(DaysToMaturity - @TargetMaturityDays))
  FROM #data d2
  WHERE d1.Date = d2.Date
        AND DaysToMaturity > @TargetMaturityDays
)
      AND TargetDistance >= 0
ORDER BY Date

-- Lower strike, shorter maturity
SELECT *
INTO #LS_BM
FROM #data d1
WHERE abs(DaysToMaturity - @TargetMaturityDays) = (
  SELECT min(abs(DaysToMaturity - @TargetMaturityDays))
  FROM #data d2
  WHERE d1.Date = d2.Date
        AND DaysToMaturity < @TargetMaturityDays
)
      AND TargetDistance <= 0
ORDER BY Date

-- Lower strike, longer maturity
SELECT *
INTO #LS_AM
FROM #data d1
WHERE abs(DaysToMaturity - @TargetMaturityDays) = (
  SELECT min(abs(DaysToMaturity - @TargetMaturityDays))
  FROM #data d2
  WHERE d1.Date = d2.Date
        AND DaysToMaturity > @TargetMaturityDays
)
      AND TargetDistance <= 0
ORDER BY Date

-- Combine data
SELECT
  *,
  'HS-BM' AS Code
FROM #HS_BM d1
WHERE TargetDistance = (
  SELECT min(TargetDistance)
  FROM #HS_BM d2
  WHERE d1.Date = d2.Date
)
UNION
SELECT
  *,
  'HS-AM' AS Code
FROM #HS_AM d1
WHERE TargetDistance = (
  SELECT min(TargetDistance)
  FROM #HS_AM d2
  WHERE d1.Date = d2.Date
)
UNION
SELECT
  *,
  'LS-BM' AS Code
FROM #LS_BM d1
WHERE TargetDistance = (
  SELECT max(TargetDistance)
  FROM #LS_BM d2
  WHERE d1.Date = d2.Date
)
UNION
SELECT
  *,
  'LS-AM' AS Code
FROM #LS_AM d1
WHERE TargetDistance = (
  SELECT max(TargetDistance)
  FROM #LS_AM d2
  WHERE d1.Date = d2.Date
>>>>>>> e033ed02045bbc876fe4e00745123fe77f4571fe
)
ORDER BY Date

DROP TABLE #data, #HS_AM, #HS_BM, #LS_AM, #LS_BM

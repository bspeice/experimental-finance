-- TODO: description 

-- Parameters are set using Python
DECLARE @Ticker VARCHAR(10) = 'KO'
DECLARE @DateStart DATETIME = '2011-1-1'
DECLARE @DateEnd DATETIME = '2013-12-31'
DECLARE @OptionType CHAR = 'C'
DECLARE @TargetMaturityDays INT = 45
DECLARE @TargetFactor FLOAT = 1

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
SELECT *
INTO #HS_BM
FROM #data d1
WHERE abs(DaysToMaturity - @TargetMaturityDays) = (
  SELECT min(abs(DaysToMaturity - @TargetMaturityDays))
  FROM #data d2
  WHERE d1.Date = d2.Date
        AND DaysToMaturity <= @TargetMaturityDays
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
        AND DaysToMaturity >= @TargetMaturityDays
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
        AND DaysToMaturity <= @TargetMaturityDays
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
        AND DaysToMaturity >= @TargetMaturityDays
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
)
ORDER BY Date

DROP TABLE #data, #HS_AM, #HS_BM, #LS_AM, #LS_BM

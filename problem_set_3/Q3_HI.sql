-- CSCO 103042
DECLARE @SecurityID INT = 103042
DECLARE @WeekStart DATETIME = '2007-1-8'
DECLARE @WeekEnd DATETIME = '2007-1-12'
DECLARE @OptionType CHAR = 'P'
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
  round(@TargetFactor * sp.ClosePrice, 2)                          AS StrikePriceTarget,
  (XF.dbo.formatStrike(op.Strike) - @TargetFactor * sp.ClosePrice) AS TargetDistance
INTO #data
FROM XFDATA.dbo.OPTION_PRICE_VIEW op
  INNER JOIN XFDATA.dbo.SECURITY_PRICE sp ON sp.SecurityID = op.SecurityID AND sp.Date = op.Date
WHERE op.SecurityID = @SecurityID
      AND op.Date BETWEEN @WeekStart AND @WeekEnd
      AND op.CallPut = @OptionType

-- Code:  HS: High Strike, LS: Low Strike, BM: Before Maturity, AM: After Maturity
SELECT *
INTO #HS_BM
FROM #data d1
WHERE abs(DaysToMaturity - 45) = (
  SELECT min(abs(DaysToMaturity - 45))
  FROM #data d2
  WHERE d1.Date = d2.Date
        AND DaysToMaturity <= 45
)
      AND TargetDistance >= 0
ORDER BY Date

SELECT *
INTO #HS_AM
FROM #data d1
WHERE abs(DaysToMaturity - 45) = (
  SELECT min(abs(DaysToMaturity - 45))
  FROM #data d2
  WHERE d1.Date = d2.Date
        AND DaysToMaturity >= 45
)
      AND TargetDistance >= 0
ORDER BY Date

SELECT *
INTO #LS_BM
FROM #data d1
WHERE abs(DaysToMaturity - 45) = (
  SELECT min(abs(DaysToMaturity - 45))
  FROM #data d2
  WHERE d1.Date = d2.Date
        AND DaysToMaturity <= 45
)
      AND TargetDistance <= 0
ORDER BY Date

SELECT *
INTO #LS_AM
FROM #data d1
WHERE abs(DaysToMaturity - 45) = (
  SELECT min(abs(DaysToMaturity - 45))
  FROM #data d2
  WHERE d1.Date = d2.Date
        AND DaysToMaturity >= 45
)
      AND TargetDistance <= 0
ORDER BY Date

-- Select 4 options having....
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

DROP TABLE #data, #HS_AM, #HS_BM, #LS_AM, #LS_BM
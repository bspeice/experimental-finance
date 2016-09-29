-- CSCO 103042
DECLARE @SecurityID INT = 103042

-- Get all relevant data
SELECT
  op.Date,
  sp.ClosePrice                         AS StockPrice,
  op.CallPut,
  op.Expiration,
  XF.dbo.formatStrike(op.Strike)        AS Strike,
  XF.dbo.mbbo(op.BestBid, op.BestOffer) AS MBBO,
  op.ImpliedVolatility,
  op.OpenInterest,
  op.Volume
INTO #data
FROM XFDATA.dbo.OPTION_PRICE_VIEW op
  INNER JOIN XFDATA.dbo.SECURITY_PRICE sp ON sp.SecurityID = op.SecurityID AND sp.Date = op.Date
WHERE op.SecurityID = @SecurityID
      AND op.Date BETWEEN '2007-1-22' AND '2007-1-26'
--and op.CallPut = 'C'

-- Problem 3. Synthetic ATM with 45 days to maturity
-- Check missing dates
SELECT
  *,
  datediff(DAY, Date, Expiration) AS DaysToMaturity
INTO #data3
FROM #data

-- Closest to ATM with Maturity <= 45 Days
SELECT *
INTO #P3below
FROM #data3 d1
WHERE abs(DaysToMaturity - 45) = (
  SELECT min(abs(DaysToMaturity - 45))
  FROM #data3 d2
  WHERE d1.Date = d2.Date
        AND DaysToMaturity <= 45
)
      AND Strike BETWEEN StockPrice * 0.85 AND StockPrice * 1.11
      AND DaysToMaturity <= 45

SELECT *
FROM #P3below

DROP TABLE #data, #data3, #P3below

-- CSCO 103042
DECLARE @SecurityID INT = 103042

-- Get all relevant data
SELECT
  op.Date,
  sp.ClosePrice                                       AS StockPrice,
  op.CallPut,
  op.Expiration,
  XF.dbo.formatStrike(op.Strike)                      AS Strike,
  ABS(sp.ClosePrice - XF.dbo.formatStrike(op.Strike)) AS ATMdistance,
  XF.dbo.mbbo(op.BestBid, op.BestOffer)               AS MBBO,
  op.ImpliedVolatility,
  op.OpenInterest,
  op.Volume
INTO #data
FROM XFDATA.dbo.OPTION_PRICE_VIEW op
  INNER JOIN XFDATA.dbo.SECURITY_PRICE sp ON sp.SecurityID = op.SecurityID AND sp.Date = op.Date
WHERE op.SecurityID = @SecurityID
      AND op.Date BETWEEN '2007-1-22' AND '2007-1-26'
      AND op.CallPut = 'C'

-- Problem 3. Synthetic ATM with 45 days to maturity
-- Check missing dates
SELECT
  *,
  datediff(DAY, Date, Expiration) AS DaysToMaturity
INTO #data3
FROM #data

-- Closest to ATM with Maturity >= 45 Days
SELECT *
INTO #P3above
FROM #data3 d1
WHERE abs(DaysToMaturity - 45) = (
  SELECT min(abs(DaysToMaturity - 45))
  FROM #data3 d2
  WHERE d1.Date = d2.Date
        AND DaysToMaturity >= 45
)
      AND Strike BETWEEN StockPrice * 0.80 AND StockPrice * 1.20
      AND DaysToMaturity >= 45

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
      AND Strike BETWEEN StockPrice * 0.80 AND StockPrice * 1.20
      AND DaysToMaturity <= 45

INSERT INTO #P3above
(Date, StockPrice, CallPut, Expiration, Strike, MBBO, ImpliedVolatility, OpenInterest, Volume, DaysToMaturity, ATMdistance)
  SELECT
    Date,
    StockPrice,
    CallPut,
    Expiration,
    Strike,
    MBBO,
    ImpliedVolatility,
    OpenInterest,
    Volume,
    DaysToMaturity,
    ATMdistance
  FROM #P3below

SELECT *
FROM #P3above
ORDER BY Date

DROP TABLE #data, #data3, #P3above, #P3below

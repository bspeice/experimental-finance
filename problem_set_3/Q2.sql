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
      AND op.Date BETWEEN '2007-1-1' AND '2007-12-31'
      AND op.CallPut = 'C'

-- Extract the 2nd series
SELECT
  *,
  ROUND(ABS((SIGN(d1.StockPrice - d1.Strike) + 1) / 2 * (d1.StockPrice - d1.Strike)), 2) AS IntrinsicValue
INTO #SecondSeries
FROM #data d1
WHERE Expiration = (
  SELECT min(Expiration)
  FROM #data d2
  WHERE d2.Date = d1.Date
        AND Expiration > (SELECT min(Expiration)
                          FROM #data d3
                          WHERE d3.Date = d1.Date
                          GROUP BY Date)
  GROUP BY Date
)

-- Extract the 2nd series ATM volatility history
-- ATM is the option with Strike closest to current Stock Price
SELECT
  identity(int) AS ID,
  Date,
  ImpliedVolatility
INTO #SecondSeriesATM
FROM #SecondSeries s1
WHERE abs(StockPrice - Strike) = (
  SELECT min(abs(StockPrice - Strike))
  FROM #SecondSeries s2
  WHERE s1.Date = s2.Date
        AND s1.Expiration = s2.Expiration
)
ORDER BY Date

-- Find biggest (absolute) changes in volatility
SELECT TOP 3
  Date,
  ImpliedVolChange
FROM (
       SELECT
         s1.Date,
         s1.ImpliedVolatility,
         s1.ImpliedVolatility - s2.ImpliedVolatility AS ImpliedVolChange
       FROM #SecondSeriesATM s1
         INNER JOIN #SecondSeriesATM s2 ON s1.ID - 1 = s2.ID
     ) dat
ORDER BY abs(ImpliedVolChange) DESC

DROP TABLE #data, #SecondSeries, #SecondSeriesATM

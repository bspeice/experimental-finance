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
  op.ImpliedVolatility
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

-- Display second series options with POP > 0.5 
SELECT
  *,
  MBBO - IntrinsicValue AS POP,
  Strike / StockPrice   AS Moneyness
FROM #SecondSeries
WHERE ImpliedVolatility > 0
      AND MBBO - IntrinsicValue > 0.5
ORDER BY Date, Strike / StockPrice ASC

DROP TABLE #data, #SecondSeries
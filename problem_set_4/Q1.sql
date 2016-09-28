-- KO 103125

SELECT
  op.Date,
  op.SecurityID,
  XF.dbo.formatStrike(op.Strike)                      AS Strike,
  op.Expiration,
  op.CallPut,
  XF.dbo.mbbo(op.BestBid, op.BestOffer)               AS MBBO,
  op.ImpliedVolatility,
  op.Volume,
  op.OpenInterest,
  sp.ClosePrice,
  abs(sp.ClosePrice - XF.dbo.formatStrike(op.Strike)) AS StrikeDiff
INTO #Coke
FROM XFDATA.dbo.OPTION_PRICE_VIEW op
  INNER JOIN XFDATA.dbo.SECURITY_PRICE sp ON sp.Date = op.Date AND sp.SecurityID = op.SecurityID
WHERE op.SecurityID = 103125


SELECT *
FROM #Coke


SELECT DISTINCT Expiration
FROM #Coke
ORDER BY 1

SELECT
  DATEPART(WEEKDAY, Expiration),
  count(*)
FROM #Coke
GROUP BY DATEPART(WEEKDAY, Expiration)

DROP TABLE #Coke
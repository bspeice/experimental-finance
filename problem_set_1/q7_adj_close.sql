SELECT
  sp.ClosePrice / sp.AdjustmentFactor as 'Adjusted Close',
  sp.Date
FROM XFDATA.dbo.SECURITY s
  INNER JOIN XFDATA.dbo.SECURITY_PRICE sp ON s.SecurityID = sp.SecurityID
WHERE s.Ticker = 'KO'
  AND sp.Date BETWEEN '2011-01-01' AND '2011-12-31'
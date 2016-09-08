SELECT
  MIN(sp.ClosePrice) as min_price,
  MAX(SP.ClosePrice) as max_price,
  YEAR(sp.Date) as year,
  MONTH(sp.Date) as month

FROM XFDATA.dbo.SECURITY s
  INNER JOIN XFDATA.dbo.SECURITY_PRICE sp on s.SecurityID = sp.SecurityID
WHERE s.Ticker = 'KO'
GROUP BY YEAR(sp.Date), MONTH(sp.Date)
ORDER BY YEAR(sp.Date), month(sp.Date)
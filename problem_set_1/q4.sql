SELECT COUNT(DISTINCT s.Ticker) as tickers, YEAR(sp.Date) as year
FROM XFDATA.dbo.SECURITY s
  INNER JOIN XFDATA.dbo.SECURITY_PRICE sp on s.SecurityID = sp.SecurityID

WHERE
  MONTH(sp.Date) = 1
  AND DAY(sp.Date) < 4
  AND s.IssueType = '0' /* Common Stock */

GROUP BY YEAR(sp.Date)

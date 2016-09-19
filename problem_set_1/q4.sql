SELECT COUNT(s.Ticker) as tickers, YEAR(sp.Date) as year
FROM XFDATA.dbo.SECURITY s
  INNER JOIN XFDATA.dbo.SECURITY_PRICE sp on s.SecurityID = sp.SecurityID

WHERE
  sp.Date in (SELECT MIN(sp.Date) FROM XFDATA.dbo.SECURITY_PRICE sp GROUP BY YEAR(sp.Date))
  AND s.IssueType = '0' /* Common Stock */

GROUP BY YEAR(sp.Date)

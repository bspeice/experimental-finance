SELECT TOP 200 *
FROM XFDATA.dbo.OPTION_PRICE_2002_02 op
  INNER JOIN XFDATA.dbo.SECURITY s ON op.SecurityID = s.SecurityID
  INNER JOIN XFDATA.dbo.SECURITY_PRICE sp on s.SecurityID = sp.SecurityID
WHERE s.Ticker = 'SLB'
      and sp.Date = '2002-02-12'
      AND op.Date = '2002-02-12'
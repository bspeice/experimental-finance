-- Parameters are set externally
declare @SecID int = {sec_id} 
declare @DateStart datetime = '{date_start}'  -- yyyy-MM-dd
declare @DateEnd datetime = '{date_end}'      -- yyyy-MM-dd

SELECT
	Expiration
FROM XFDATA.dbo.SECURITY_NAME s
  INNER JOIN XFDATA.dbo.SECURITY_PRICE sp ON s.SecurityID = sp.SecurityID
  INNER JOIN XFDATA.dbo.OPTION_PRICE_VIEW op ON sp.SecurityID = op.SecurityID
                                                AND sp.Date = op.Date

WHERE s.SecurityID = @SecID AND Expiration BETWEEN @DateStart AND @DateEnd
GROUP BY Expiration
ORDER BY Expiration

SELECT COUNT(*)
FROM (
       SELECT COUNT(DISTINCT sn.Ticker) AS num_tickers,
              sn.SecurityID
       FROM XFDATA.dbo.SECURITY_NAME sn
              INNER JOIN XFDATA.dbo.SECURITY s on s.SecurityID = sn.SecurityID
       WHERE s.Class = '0'
       GROUP BY sn.SecurityID
     ) sub
WHERE num_tickers > 1

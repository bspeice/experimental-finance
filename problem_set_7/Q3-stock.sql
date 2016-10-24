SELECT sp.*
FROM XFDATA.dbo.SECURITY_PRICE sp
  INNER JOIN XFDATA.dbo.SECURITY_NAME sn ON sp.SecurityID = sn.SecurityID
WHERE
  sn.Ticker = 'CEPH'
  AND sp.Date BETWEEN '2011-01-01' AND '2011-06-01'
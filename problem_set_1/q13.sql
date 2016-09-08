SELECT COUNT(*)
FROM (
  SELECT COUNT(DISTINCT sn.IssuerDescription) AS distinct_issuers
      FROM XFDATA.dbo.SECURITY_NAME sn
        INNER JOIN XFDATA.dbo.SECURITY s ON sn.SecurityID = s.SecurityID
      WHERE s.Class = '0'
      GROUP BY sn.Ticker
) sub
WHERE sub.distinct_issuers > 1
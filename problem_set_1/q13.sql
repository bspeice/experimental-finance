SELECT COUNT(*)
FROM (
  SELECT COUNT(DISTINCT sn.SecurityID) AS distinct_issuers
      FROM XFDATA.dbo.SECURITY_NAME sn
        INNER JOIN XFDATA.dbo.SECURITY s ON sn.SecurityID = s.SecurityID
      WHERE s.IssueType = '0'
        AND sn.Ticker NOT IN ('?')
        AND sn.Ticker NOT LIKE 'ZZZZ%'
      GROUP BY sn.Ticker
) sub
WHERE sub.distinct_issuers > 1
/*
The LEFT OUTER JOIN ensures that if there is no match
(i.e. no OPTION_INFO available) that oi.SecurityID is
NULL. Thus, to find non-optionable stocks we need to find
those where there is no OPTION_INFO available.
 */
SELECT DISTINCT s.Ticker, s.SecurityID
FROM XFDATA.dbo.SECURITY s
  INNER JOIN XFDATA.dbo.SECURITY_NAME sn on s.SecurityID = sn.SecurityID
  LEFT OUTER JOIN XFDATA.dbo.OPTION_INFO oi on s.SecurityID = oi.SecurityID
WHERE s.IssueType = '0'
  and oi.SecurityID is NULL
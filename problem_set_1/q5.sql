SELECT s.*, sp.*
FROM XFDATA.dbo.SECURITY s
  LEFT JOIN XFDATA.dbo.SECURITY_PRICE sp ON s.SecurityID = sp.SecurityID
                                            AND sp.Date = '2015-01-15'
WHERE sp.ClosePrice is NULL

SELECT ticker
FROM XFDATA.dbo.SECURITY s
LEFT JOIN XFDATA.dbo.SECURITY_PRICE sp ON s.SecurityID = sp.SecurityID
WHERE sp.ClosePrice is NULL
  AND sp.Date = '2015-01-15'

/*
Difference is in how join is processed, need to think through what exactly
is going on.
 */
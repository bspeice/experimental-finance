/*
If you forget the `DISTINCT` clause in counting, you get 7230 tickers,
not 6862. The problem specifically asks for unique tickers, so 7230 is an
incorrect answer.
 */

SELECT COUNT(DISTINCT s.Ticker) num_tickers
FROM XFDATA.dbo.SECURITY_PRICE sp
INNER JOIN XFDATA.dbo.SECURITY s ON sp.SecurityID = s.SecurityID
WHERE sp.Date = '2012-09-26'
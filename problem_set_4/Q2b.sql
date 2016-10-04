/*
When running this query, we pull out more data than is actually needed. PPN use +/- 10
days' worth of data, and we will do the same eventually. First though, because SQL
isn't aware of holidays, we actually pull out 20 days' +/- the expiration to give
ourselves a buffer during processing. It's much easier to handle trading day logic
in Python than it is in SQL calculating trading day difference.
 */
SELECT
  s.Ticker,
  sp.ClosePrice,
  sp.Volume,
  sp.Date,
  op.Strike,
  -- Sum the Open Interest to get both calls and puts
  SUM(op.OpenInterest) as OpenInterest,
  -- Average the implied volatility - I'm not sure there's
  -- a better measure that could be used.
  -- It's only for binning though, and not actual calculations,
  -- so we assume this is an OK guess.
  AVG(op.ImpliedVolatility) as ImpliedVolatility,
  op.Expiration
FROM XFDATA.dbo.OPTION_PRICE_VIEW op
  INNER JOIN XFDATA.dbo.SECURITY_PRICE sp ON op.SecurityID = sp.SecurityID
                                             AND ABS(DATEDIFF(DAY, op.Expiration, sp.Date)) < 20
  INNER JOIN XFDATA.dbo.SECURITY s ON sp.SecurityID = s.SecurityID
WHERE op.Expiration BETWEEN '2007-01-01' AND '2009-01-01'
      AND sp.Date BETWEEN '2006-12-01' AND '2009-02-01' -- Stock price buffer
      AND ABS(DATEDIFF(DAY, sp.Date, op.Expiration)) < 20

-- Massive GROUP BY clause cuts down on duplicate data we don't
-- need that is introduced by other parameters being unique
GROUP BY
  s.Ticker,
  sp.ClosePrice,
  sp.Volume,
  sp.Date,
  op.Strike,
  op.Expiration

ORDER BY s.Ticker, sp.Date, op.Strike
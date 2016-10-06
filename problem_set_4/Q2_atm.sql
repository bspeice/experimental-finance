/*
When running this query, we pull out more data than is actually needed. PPN use +/- 10
days' worth of data, and we will do the same eventually. First though, because SQL
isn't aware of holidays, we actually pull out 20 days' +/- the expiration to give
ourselves a buffer during processing. It's much easier to handle trading day logic
in Python than it is in SQL calculating trading day differences.
 */
WITH strike_diff as (
    SELECT
      s.Ticker,
      sp.ClosePrice,
      sp.Volume,
      sp.Date,
      op.Strike,
      -- Sum the Open Interest to get both calls and puts
      SUM(op.OpenInterest)                               AS OpenInterest,
      op.Expiration,
      -- AVG ignores NULL values, so if we have an invalid ImpliedVolatility we can just
      -- set it to NULL to exclude it from calculations. Then the correct value is
      -- applied everywhere
      AVG(CASE WHEN op.ImpliedVolatility <= 0 THEN NULL ELSE op.ImpliedVolatility END) as ImpliedVolatility,
      ABS(sp.ClosePrice - XF.dbo.formatStrike(op.Strike)) AS StrikeDiff
    FROM XFDATA.dbo.OPTION_PRICE_VIEW op
      INNER JOIN XFDATA.dbo.SECURITY_PRICE sp ON op.SecurityID = sp.SecurityID
                                                 AND ABS(DATEDIFF(DAY, op.Expiration, sp.Date)) < 20
      INNER JOIN XFDATA.dbo.SECURITY s ON sp.SecurityID = s.SecurityID
    WHERE op.Expiration BETWEEN '2007-01-01' AND '2009-01-01'
          AND sp.Date BETWEEN '2006-12-01' AND '2009-02-01' -- Stock price buffer
          AND s.Ticker IN (SELECT sp500.ticker
                           FROM XF.dbo.sp500)
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
)

SELECT strike_diff.*
FROM strike_diff
  INNER JOIN (
    -- We don't need to group on expiration as well, since
    -- that doesn't affect what is currently ATM
    SELECT MIN(strike_diff.StrikeDiff) as StrikeDiff,
      strike_diff.Date,
      strike_diff.Ticker
    FROM strike_diff
    GROUP BY strike_diff.Date, strike_diff.Ticker
    ) sd_grouped ON strike_diff.StrikeDiff = sd_grouped.StrikeDiff
                    AND strike_diff.Date = sd_grouped.Date
                    AND strike_diff.Ticker = sd_grouped.Ticker

ORDER BY strike_diff.Ticker, strike_diff.Date, strike_diff.Strike
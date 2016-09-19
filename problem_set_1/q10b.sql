/*
The way I'm interpreting this question is to say that the "ATM"
strike is the strike which is closest to the close price (NOT the
adjusted close, as the Option_Price file doesn't adjust strikes) for
each day.

The query is a bit strange - the `WITH` clause selects out a table that
matches all possible strikes against the close price for each day. From there,
we join this table against the row with the smallest difference
between close and strike for each day to get our final result.
 */
WITH diff_table AS (
    SELECT
      MAX(sp.ClosePrice)                                         AS ClosePrice,
      MIN(CONVERT(FLOAT, op.Strike) / 1000)                      AS Strike,
      ABS(MAX(sp.ClosePrice) - CONVERT(FLOAT, op.Strike) / 1000) AS strike_diff,
      op.Date as Date,
      MIN(op.ImpliedVolatility) AS ImpliedVolatility

    FROM XFDATA.dbo.SECURITY_NAME sn
      INNER JOIN XFDATA.dbo.SECURITY_PRICE sp ON sn.SecurityID = sp.SecurityID
      INNER JOIN XFDATA.dbo.OPTION_PRICE_VIEW op ON sp.SecurityID = op.SecurityID
                                                    AND sp.Date = op.Date

    WHERE sn.Ticker = 'PG'
          AND op.Date BETWEEN '2008-01-01' AND '2009-01-01'
      AND op.ImpliedVolatility IS NOT NULL
      AND op.ImpliedVolatility > 0

    /*
  Sometimes the same strike expires on different dates,
  so the GROUP BY on Strike value removes duplicated rows
   */
    GROUP BY op.Strike, op.Date
)

SELECT diff_table.*
FROM diff_table
  INNER JOIN (
               SELECT
                 MIN(diff_table.strike_diff) AS strike_diff,
                 diff_table.Date
               FROM diff_table
               GROUP BY diff_table.Date
             ) dt_grouped ON diff_table.strike_diff = dt_grouped.strike_diff
                             AND diff_table.Date = dt_grouped.Date
ORDER BY diff_table.Date

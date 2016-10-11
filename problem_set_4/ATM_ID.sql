-- Parameters are set externally
declare @SecID int = {sec_id} 
declare @DateStart datetime = '{date_start}'  -- yyyy-MM-dd
declare @DateEnd datetime = '{date_end}'      -- yyyy-MM-dd

SELECT
      sp.Date,
      MAX(sp.ClosePrice)                                         AS ClosePrice,
      MIN(CONVERT(FLOAT, op.Strike) / 1000)                      AS Strike,
      ABS(MAX(sp.ClosePrice) - CONVERT(FLOAT, op.Strike) / 1000) AS strike_diff
INTO diff_table
FROM XFDATA.dbo.SECURITY_NAME sn
      INNER JOIN XFDATA.dbo.SECURITY_PRICE sp ON sn.SecurityID = sp.SecurityID
      INNER JOIN XFDATA.dbo.OPTION_PRICE_VIEW op ON sp.SecurityID = op.SecurityID
                                                    AND sp.Date = op.Date

WHERE sp.SecurityID = @SecID AND sp.Date BETWEEN @DateStart AND @DateEnd

/*
Sometimes the same strike expires on different dates,
so the GROUP BY on Strike value removes duplicated rows
*/
GROUP BY op.Strike, sp.Date

SELECT
  diff_table.*
FROM diff_table
  INNER JOIN (
               SELECT
                 MIN(diff_table.strike_diff) AS strike_diff,
                 diff_table.Date
               FROM diff_table
               GROUP BY diff_table.Date
             ) dt_grouped ON diff_table.strike_diff = dt_grouped.strike_diff
                             AND diff_table.Date = dt_grouped.Date
ORDER BY Date

drop TABLE diff_table

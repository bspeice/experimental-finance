SELECT
  trades.EarningsDate,
  trades.Ticker,
  ABS(trades.ExpDiff) AS ExpDiff,
  trades.StrikeDiff,
  trades.TradeOpenPrice,
  trades.TradeClosePrice,
  (trades.OpenInterest - trades.OpenInterestPrior) as OpenInterestIncrease,
  trades.Surprise,
  trades.CallPut
INTO #strikediff
FROM XF.db_datawriter.bcs2149_earningsTrades trades

WHERE trades.BusDaysPrior = {days_prior}
      AND trades.BusDaysAfter = {days_after}
      AND trades.Surprise != 0;

SELECT #strikediff.*
FROM #strikediff
  INNER JOIN (
               SELECT
                 MIN(#strikediff.StrikeDiff) AS StrikeDiff,
                 MIN(#strikediff.ExpDiff)    AS ExpDiff,
                 #strikediff.EarningsDate,
                 #strikediff.Ticker
               FROM #strikediff
               GROUP BY #strikediff.EarningsDate, #strikediff.Ticker
             ) grouped ON #strikediff.Ticker = grouped.Ticker
                          AND #strikediff.EarningsDate = grouped.EarningsDate
                          AND #strikediff.ExpDiff = grouped.ExpDiff
                          AND #strikediff.StrikeDiff = grouped.StrikeDiff
ORDER BY #strikediff.EarningsDate, #strikediff.Ticker
SELECT
  trades.EarningsDate,
  trades.Ticker,
  trades.Strike,
  ABS(trades.ExpDiff)                              AS ExpDiff,
  trades.StrikeDiff,
  trades.TradeOpenPrice,
  trades.TradeClosePrice,
  (trades.OpenInterest - trades.OpenInterestPrior) AS OpenInterestIncrease,
  trades.Surprise,
  trades.CallPut,
  -- Column is positive when OTM, negative when ITM
  CASE WHEN trades.CallPut = 'C'
    THEN (trades.TradeOpenPrice - trades.Strike)
  ELSE (trades.Strike - trades.TradeOpenPrice) END AS StrikeDiffNorm
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
                          AND #strikediff.StrikeDiff != grouped.StrikeDiff
WHERE #strikediff.StrikeDiffNorm > 0
ORDER BY #strikediff.EarningsDate, #strikediff.Ticker, #strikediff.StrikeDiff
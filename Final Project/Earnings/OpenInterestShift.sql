SELECT
  op.Date                                             AS Date,
  sn.Ticker                                           AS Ticker,
  op.Expiration                                       AS Expiration,
  op.OpenInterest                                     AS OpenInterest,
  op_before.OpenInterest                              AS OpenInterestBefore,
  op.CallPut                                          AS CallPut,
  XF.dbo.formatStrike(op.Strike)                      AS Strike,
  ABS(XF.dbo.formatStrike(op.Strike) - sp.ClosePrice) AS StrikeDiff,
  sp.ClosePrice / sp.AdjustmentFactor                 AS ClosePrice,
  sp_after.ClosePrice / sp_after.AdjustmentFactor     AS ClosePriceAfter,
  DATEDIFF(DAY, sp_after.Date, op.Expiration)         AS ExpirationDiff
INTO #strikediff
FROM XFDATA.dbo.OPTION_PRICE_VIEW op
  INNER JOIN XFDATA.dbo.OPTION_PRICE_VIEW op_before ON op_before.SecurityID = op.SecurityID
                                                       AND op_before.Strike = op.Strike
                                                       AND op_before.CallPut = op.CallPut
                                                       AND op_before.Expiration = op.Expiration
  INNER JOIN XFDATA.dbo.SECURITY_PRICE sp ON op.SecurityID = sp.SecurityID
                                             AND op.Date = sp.Date
  INNER JOIN XFDATA.dbo.SECURITY_PRICE sp_after ON sp.SecurityID = sp_after.SecurityID
  INNER JOIN XFDATA.dbo.SECURITY_NAME sn ON sp.SecurityID = sn.SecurityID

WHERE {conditions};

SELECT #strikediff.*
FROM #strikediff
  INNER JOIN (
               SELECT
                 MIN(#strikediff.StrikeDiff)          AS StrikeDiff,
                 MIN(ABS(#strikediff.ExpirationDiff)) AS ExpDiff,
                 #strikediff.Date,
                 #strikediff.Ticker
               FROM #strikediff
               GROUP BY #strikediff.Date, #strikediff.Ticker
             ) sd_grouped ON #strikediff.StrikeDiff = sd_grouped.StrikeDiff
                             AND #strikediff.ExpirationDiff = sd_grouped.ExpDiff
                             AND #strikediff.Date = sd_grouped.Date
                             AND #strikediff.Ticker = sd_grouped.Ticker
GROUP BY
  #strikediff.Date,
  #strikediff.Ticker,
  #strikediff.Expiration,
  #strikediff.OpenInterest,
  #strikediff.OpenInterestBefore,
  #strikediff.CallPut,
  #strikediff.Strike,
  #strikediff.StrikeDiff,
  #strikediff.ClosePrice,
  #strikediff.ClosePriceAfter,
  #strikediff.ExpirationDiff
ORDER BY #strikediff.Date

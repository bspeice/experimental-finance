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

FROM XFDATA.dbo.OPTION_PRICE_VIEW op
  INNER JOIN XFDATA.dbo.OPTION_PRICE_VIEW op_before ON op.SecurityID = op_before.SecurityID
                                                       AND ABS(DATEDIFF(DAY, op.Date - {days_prior}, op_before.Date)) < {window}
  INNER JOIN XFDATA.dbo.SECURITY_PRICE sp ON op.SecurityID = sp.SecurityID
                                             AND op.Date = sp.Date
  INNER JOIN XFDATA.dbo.SECURITY_PRICE sp_after ON op.SecurityID = sp.SecurityID AND
                                                   ABS(DATEDIFF(DAY, sp.Date + {days_after}, sp_after.Date)) < {window}
  INNER JOIN XFDATA.dbo.SECURITY_NAME sn ON sp.SecurityID = sn.SecurityID
  INNER JOIN XF.db_datawriter.bcs2149_earnings earn ON sn.Ticker = earn.Ticker
                                                       AND op.Date = earn.NormDate

WHERE earn.Ticker IN ({tickers}) AND
  DATEPART(DAY, op_before.Date) < 6 AND -- Weekday
  DATEPART(DAY, sp_after.Date) < 6 -- Weekday
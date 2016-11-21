INSERT INTO XF.db_datawriter.bcs2149_earningsTrades
  SELECT
    op.SecurityID                                          AS SecurityId,
    op.Date                                                AS EarningsDate,
    '{prior_date}'                                         AS PriorCheck,
    --'2013-01-01'                                           AS PriorCheck,
    '{trade_close}'                                        AS CloseDate,
    --'2013-01-01'                                           AS CloseDate,
    op.Expiration                                          AS Expiration,
    op.OpenInterest                                        AS OpenInterest,
    op_before.OpenInterest                                 AS OpenInterestPrior,
    op.CallPut                                             AS CallPut,
    CONVERT(DECIMAL(6, 2), XF.dbo.formatStrike(op.Strike)) AS Strike,
    CONVERT(DECIMAL(6, 2), sp.OpenPrice)                   AS TradeOpenPrice,
    CONVERT(DECIMAL(6, 2), sp_after.ClosePrice)            AS TradeClosePrice,
    CONVERT(DECIMAL(4, 2), earn.Surprise)                  AS Surprise,
    CONVERT(DECIMAL(4, 2), earn.EPS)                       AS EPS,
    '{ticker}'                                             AS Ticker,
    {bus_days_prior}                                       AS BusDaysPrior,
    --1                                                      AS BusDaysPrior,
    {bus_days_after}                                       AS BusDaysAfter,
    --30                                                     AS BusDaysAfter,
    ABS(XF.dbo.formatStrike(op.Strike) - sp.OpenPrice)     AS StrikeDiff,
    DATEDIFF(DAY, sp_after.Date, op.Expiration)            AS ExpirationDiff

  FROM XFDATA.dbo.OPTION_PRICE_VIEW op
    INNER JOIN XFDATA.dbo.OPTION_PRICE_VIEW op_before ON op_before.SecurityID = op.SecurityID
                                                         AND op_before.Strike = op.Strike
                                                         AND op_before.CallPut = op.CallPut
                                                         AND op_before.Expiration = op.Expiration
                                                         AND op_before.SpecialSettlement = 0
    INNER JOIN XFDATA.dbo.SECURITY_PRICE sp ON op.SecurityID = sp.SecurityID
                                               AND op.Date = sp.Date
    INNER JOIN XFDATA.dbo.SECURITY_PRICE sp_after ON sp.SecurityID = sp_after.SecurityID
    INNER JOIN XF.db_datawriter.bcs2149_earnings earn ON op.Date = earn.NormDate

  WHERE op.SecurityID IN (
    SELECT sn.SecurityId
    FROM XFDATA.dbo.SECURITY_NAME sn
    WHERE sn.Ticker = '{ticker}'
  )
        AND earn.Ticker = '{ticker}'
        AND sp_after.Date = '{trade_close}'
        AND op_before.Date = '{prior_date}'
        AND op.Date = '{trade_open}'
        AND op.SpecialSettlement = 0;
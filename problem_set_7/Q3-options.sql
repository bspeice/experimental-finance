SELECT
  op.Delta,
  op.CallPut,
  op.Date,
  op.BestBid,
  op.BestOffer,
  XF.dbo.formatStrike(op.Strike)        AS AdjStrike,
  op.Expiration,
  sp.ClosePrice,
  zc.Rate,
  ABS(DATEDIFF(DAY, sp.Date, op.Expiration)) AS TTE_sec,
  ABS(DATEDIFF(DAY, zc.Date + zc.Days, op.Expiration)) AS TTE_zc
INTO #diff_table
FROM XFDATA.dbo.OPTION_PRICE_VIEW op
  INNER JOIN XFDATA.dbo.SECURITY_NAME sn ON op.SecurityID = sn.SecurityID
  INNER JOIN XFDATA.dbo.SECURITY_PRICE sp ON op.SecurityID = sp.SecurityID
                                             AND op.Date = sp.Date
  INNER JOIN XFDATA.dbo.ZERO_CURVE zc ON op.Date = zc.Date

WHERE sn.Ticker = 'CEPH'
      AND op.Date BETWEEN '2011-01-01' AND '2011-06-01'
      AND op.Delta BETWEEN -1 AND 1


SELECT
  #diff_table.Date,
  #diff_table.Delta,
  #diff_table.ClosePrice,
  #diff_table.AdjStrike,
  #diff_table.BestBid,
  #diff_table.BestOffer,
  #diff_table.Expiration,
  #diff_table.TTE_sec,
  #diff_table.CallPut,
  #diff_table.TTE_zc,
  #diff_table.Rate AS ZC_Rate
FROM #diff_table
  INNER JOIN (
               SELECT
                 MIN(#diff_table.TTE_sec) AS MinTTE_sec,
                 MIN(#diff_table.TTE_zc)  AS MinTTE_zc,
                 #diff_table.Date
               FROM #diff_table
               GROUP BY #diff_table.Date
             ) dt_grouped ON #diff_table.TTE_sec = dt_grouped.MinTTE_sec
                             AND #diff_table.TTE_zc = dt_grouped.MinTTE_zc

GROUP BY
  #diff_table.Date,
  #diff_table.Delta,
  #diff_table.ClosePrice,
  #diff_table.AdjStrike,
  #diff_table.BestBid,
  #diff_table.BestOffer,
  #diff_table.Expiration,
  #diff_table.TTE_sec,
  #diff_table.CallPut,
  #diff_table.TTE_zc,
  #diff_table.Rate

ORDER BY
  #diff_table.Date,
  #diff_table.CallPut,
  #diff_table.Expiration
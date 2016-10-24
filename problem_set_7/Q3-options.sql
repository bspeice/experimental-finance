SELECT
  op.Delta,
  op.CallPut,
  op.Date,
  op.BestBid,
  op.BestOffer,
  XF.dbo.formatStrike(op.Strike)        AS AdjStrike,
  op.Expiration,
  sp.ClosePrice,
  DATEDIFF(DAY, sp.Date, op.Expiration) AS TTE
INTO #diff_table
FROM XFDATA.dbo.OPTION_PRICE_VIEW op
  INNER JOIN XFDATA.dbo.SECURITY_NAME sn ON op.SecurityID = sn.SecurityID
  INNER JOIN XFDATA.dbo.SECURITY_PRICE sp ON op.SecurityID = sp.SecurityID
                                             AND op.Date = sp.Date

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
  #diff_table.TTE,
  #diff_table.CallPut
FROM #diff_table
  INNER JOIN (
               SELECT
                 MIN(#diff_table.TTE) AS MinTTE,
                 #diff_table.Date
               FROM #diff_table
               GROUP BY #diff_table.Date
             ) dt_grouped ON #diff_table.TTE = dt_grouped.MinTTE

GROUP BY
  #diff_table.Date,
  #diff_table.Delta,
  #diff_table.ClosePrice,
  #diff_table.AdjStrike,
  #diff_table.BestBid,
  #diff_table.BestOffer,
  #diff_table.Expiration,
  #diff_table.TTE,
  #diff_table.CallPut

ORDER BY
  #diff_table.Date,
  #diff_table.CallPut,
  #diff_table.Expiration
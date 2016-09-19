SELECT op.Date, op.CallPut,
  XF.dbo.mbbo(op.BestBid, op.BestOffer) as MBBO,
  --(op.BestBid + op.BestOffer) / 2 as MBBO,
  XF.dbo.formatStrike(op.Strike) as Strike,
  op.Expiration
FROM XFDATA.dbo.OPTION_PRICE_VIEW op
  INNER JOIN XFDATA.dbo.SECURITY s on op.SecurityID = s.SecurityID
WHERE op.Date BETWEEN '2010-03-01' AND '2010-09-01'
  AND s.Ticker = 'QLGC'
  AND op.BestOffer < .2
GROUP BY op.Date,
  XF.dbo.mbbo(op.BestBid, op.BestOffer),
  --(op.BestBid + op.BestOffer) / 2,
  XF.dbo.formatStrike(op.Strike),
  op.CallPut,
  op.Expiration

ORDER BY
  op.Date,
  op.Expiration,
  op.CallPut,
  XF.dbo.formatStrike(op.Strike)
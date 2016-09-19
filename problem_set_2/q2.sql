SELECT TOP 200
  op.SecurityID,
  (op.BestOffer + op.BestBid) / 2 as MBBO
FROM XFDATA.dbo.OPTION_PRICE_2001_05 op
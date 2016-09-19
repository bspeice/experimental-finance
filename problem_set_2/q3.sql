SELECT TOP 200
  op.SecurityID,
  CONVERT(DECIMAL(5, 2), ROUND((op.BestOffer + op.BestBid) / 2, 2)) as MBBO
FROM XFDATA.dbo.OPTION_PRICE_2001_05 op
SELECT TOP 200
  op.SecurityID,
  -- Decimal(5, 2) implies penny pricing,
  -- and option prices not exceeding 999.99
  CONVERT(DECIMAL(5, 2), op.BestBid),
  CONVERT(DECIMAL(5, 2), op.BestOffer)
FROM XFDATA.dbo.OPTION_PRICE_2001_05 op

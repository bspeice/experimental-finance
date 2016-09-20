select top 10 
  Date, 
  SecurityID,
  XF.dbo.formatStrike(Strike) as Strike, 
  Expiration, 
  CallPut,
  BestBid, 
  BestOffer,
  (BestBid + BestOffer) / 2.0 as MBBO,
  ROUND((BestBid + BestOffer) / 2.0, 2) as MBBO_Round
from XFDATA.dbo.OPTION_PRICE_VIEW
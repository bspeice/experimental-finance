select top 10 
  Date, 
  SecurityID,
  XF.dbo.formatStrike(Strike) as Strike, 
  Expiration, 
  CallPut,
  BestBid, 
  BestOffer,
  (BestBid + BestOffer) / 2.0 as MBBO
from XFDATA.dbo.OPTION_PRICE_VIEW
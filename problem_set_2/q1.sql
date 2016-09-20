select top 10 
  Date, 
  SecurityID,
  XF.dbo.formatStrike(Strike) as Strike, 
  Expiration, 
  CallPut,
  BestBid, 
  BestOffer,
  ROUND(BestBid,2) as BestBidRnd,
  ROUND(BestOffer,2) as BestOfferRnd
from XFDATA.dbo.OPTION_PRICE_VIEW
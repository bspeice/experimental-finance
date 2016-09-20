select top 10
  op.Date, 
  XF.dbo.formatStrike(op.Strike) as Strike,
  op.Expiration, 
  op.CallPut,
  XF.dbo.mbbo(op.BestBid, op.BestOffer) as MBBO
from XFDATA.dbo.OPTION_PRICE_VIEW op
join XFDATA.dbo.SECURITY s 
  on s.SecurityID = op.SecurityID
where 
  s.Ticker = 'QLGC'
  and op.Date between '2010-3-1' and '2010-9-1'
  and op.BestOffer < 0.2
order by op.CallPut, op.Date, op.Expiration, op.Strike
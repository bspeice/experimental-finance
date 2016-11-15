declare @SecurityID int = 111051
declare @DateFrom datetime = '1999-12-1'
declare @DateTo datetime = '2000-2-1'

select op.Date, 
	dbo.formatStrike(op.Strike) as Strike,
	op.Expiration,
	op.CallPut,
	op.BestBid,
	op.BestOffer,
	(convert(float,op.BestBid) + convert(float,op.BestOffer))/2.0  as MBBO,
	op.ImpliedVolatility,
	op.Delta,
	op.Volume,
	op.OpenInterest,
	dbo.formatStrike(op.Strike) - sp.ClosePrice as StrikeDiff,
	datediff(day,op.Date,op.Expiration)/360.0 as ExpirationY,
	sp.ClosePrice as StockPrice,
	db_datawriter.InterpolateRate(datediff(day,op.date,op.Expiration),op.date)/100.0 as ZeroRate,
	case when op.BestBid > 0 then 1 else 0 end as HasMarket
from XFDATA.dbo.OPTION_PRICE_VIEW op
join XFDATA.dbo.SECURITY_PRICE sp on sp.SecurityID = op.SecurityID and sp.Date = op.Date
join XFDATA.dbo.SECURITY s on s.SecurityID = sp.SecurityID
where op.SecurityID = @SecurityID
and op.Date between @DateFrom and @DateTo
and op.Delta between -1 and 1
and op.ImpliedVolatility > 0
and op.BestBid > 0
order by op.Date, op.CallPut, op.Expiration, op.Strike

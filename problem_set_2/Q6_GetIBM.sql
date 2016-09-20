declare @date1 date = '2013-2-13'
declare @date2 date = '2013-4-16'
declare @date3 date = '2013-7-10'
--declare @date1 date = '2006-2-8'
--declare @date2 date = '2006-4-12'
--declare @date3 date = '2006-7-10'

-- IBM 106276

select c.Date, c.StockPrice, c.Expiration, c.ExpirationD, c.Strike, c.ATMdiff,
  c.MBBO as CallPrice, c.ImpliedVolatility as CallIV, c.POP as CallPOP, 
  p.MBBO as PutPrice, p.ImpliedVolatility as PutIV, p.POP as PutPOP
from
( -- Calls
	select op.Date,  sp.ClosePrice as StockPrice,CallPut, Expiration, datediff(day,op.Date,Expiration) as ExpirationD, 
	XF.dbo.formatStrike(Strike) as Strike, XF.dbo.mbbo(BestBid, BestOffer) as MBBO, ImpliedVolatility,
	XF.dbo.mbbo(BestBid, BestOffer) - (sp.ClosePrice - XF.dbo.formatStrike(Strike)) as POP,
	abs(sp.ClosePrice-op.Strike/1000.0) as ATMdiff
	from XFDATA.dbo.OPTION_PRICE_VIEW op
	inner join XFDATA.dbo.SECURITY_PRICE sp 
	  on sp.SecurityID = op.SecurityID 
	  and sp.Date = op.Date
	where 
	  op.SecurityID = 106276 
	  and op.CallPut = 'C'
	  and op.Date in (@date1,@date2,@date3)
	  and op.ImpliedVolatility > 0
	  and abs(sp.ClosePrice-op.Strike/1000.0) in (
	    select top 5 Diff
		from (
			select distinct abs(sp2.ClosePrice - op2.Strike/1000.0) as Diff
			from XFDATA.dbo.OPTION_PRICE_VIEW op2
			inner join XFDATA.dbo.SECURITY_PRICE sp2 
			  on sp2.SecurityID = op2.SecurityID
			  and sp2.Date = op2.Date
			where op2.SecurityID = op.SecurityID 
			  and op2.Date = op.Date
			  and op2.Expiration = op.Expiration
			) c
		order by Diff asc
	   )
) c
full outer join 
(
	-- Puts
	select op.Date, sp.ClosePrice as StockPrice, CallPut, Expiration, datediff(day,op.Date,Expiration) as ExpirationD, 
	XF.dbo.formatStrike(Strike) as Strike, XF.dbo.mbbo(BestBid, BestOffer) as MBBO, ImpliedVolatility,
	XF.dbo.mbbo(BestBid, BestOffer) - (XF.dbo.formatStrike(Strike) - sp.ClosePrice)  as POP,
	abs(sp.ClosePrice-op.Strike/1000.0) as ATMdiff
	from XFDATA.dbo.OPTION_PRICE_VIEW op
	inner join XFDATA.dbo.SECURITY_PRICE sp 
	  on sp.SecurityID = op.SecurityID 
	  and sp.Date = op.Date
	where 
	  op.SecurityID = 106276
	  and op.CallPut = 'P'
	  and op.Date in (@date1,@date2,@date3)
	  and op.ImpliedVolatility > 0
	  and abs(sp.ClosePrice-op.Strike/1000.0) in (
	    select top 5 Diff
		from (
			select distinct abs(sp2.ClosePrice - op2.Strike/1000.0) as Diff
			from XFDATA.dbo.OPTION_PRICE_VIEW op2
			inner join XFDATA.dbo.SECURITY_PRICE sp2 
			  on sp2.SecurityID = op2.SecurityID
			  and sp2.Date = op2.Date
			where op2.SecurityID = op.SecurityID 
			  and op2.Date = op.Date
			  and op2.Expiration = op.Expiration 
			) c
		order by Diff asc
	   )
) p on c.Date = p.Date and c.Expiration = p.Expiration and c.Strike = p.Strike
where c.MBBO is not null and p.MBBO is not null
order by c.Date, c.Expiration, c.Strike
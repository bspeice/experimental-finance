declare @date1 date = '2013-2-13'
declare @date2 date = '2013-4-16'
declare @date3 date = '2013-7-10'

-- Get yield curves from IVY
select *
from XFDATA.dbo.ZERO_CURVE
where Date in (@date1,@date2,@date3)

-- GOOG 121812
select *
from XFDATA.dbo.SECURITY_PRICE
where SecurityID = 121812 -- GOOG
and Date in (@date1,@date2,@date3)

select Date, Symbol, CallPut, Expiration, datediff(day,Date,Expiration) as ExpirationD, XF.dbo.formatStrike(Strike) as Strike, BestBid, BestOffer, XF.dbo.mbbo(BestBid, BestOffer) as MBBO, ImpliedVolatility, Volume, OpenInterest
from XFDATA.dbo.OPTION_PRICE_VIEW
where SecurityID = 121812 -- GOOG
and Date in (@date1,@date2,@date3)

select op.Date, Symbol, CallPut, Expiration, datediff(day,op.Date,Expiration) as ExpirationD, XF.dbo.formatStrike(Strike) as Strike, XF.dbo.mbbo(BestBid, BestOffer) as MBBO, ImpliedVolatility
from XFDATA.dbo.OPTION_PRICE_VIEW op
inner join XFDATA.dbo.SECURITY_PRICE sp 
  on sp.SecurityID = op.SecurityID 
  and sp.Date = op.Date
where 
  op.SecurityID = 121812 -- GOOG
  and op.Symbol not like 'GOOG7%'
  and op.Date in (@date1,@date2,@date3)
  and abs(sp.ClosePrice-op.Strike/1000.0) = (
    select min(abs(sp2.ClosePrice - op2.Strike/1000.0)) as Diff
    from XFDATA.dbo.OPTION_PRICE_VIEW op2
	inner join XFDATA.dbo.SECURITY_PRICE sp2 
      on sp2.SecurityID = op2.SecurityID
      and sp2.Date = op2.Date
    where op2.SecurityID = op.SecurityID 
      and op2.Date = op.Date
    group by op2.Date 
   )
order by op.Date


-- IBM 106276
select *
from XFDATA.dbo.SECURITY_PRICE
where SecurityID = 106276 -- IBM
and Date in (@date1,@date2,@date3)

select *
from XFDATA.dbo.DISTRIBUTION
where SecurityID = 106276 -- IBM

select Date, Symbol, CallPut, Expiration, datediff(day,Date,Expiration) as ExpirationD, XF.dbo.formatStrike(Strike) as Strike, BestBid, BestOffer, XF.dbo.mbbo(BestBid, BestOffer) as MBBO, ImpliedVolatility, Volume, OpenInterest
from XFDATA.dbo.OPTION_PRICE_VIEW
where SecurityID = 106276 -- IBM
and Date in (@date1,@date2,@date3)

select op.Date, Symbol, CallPut, Expiration, datediff(day,op.Date,Expiration) as ExpirationD, XF.dbo.formatStrike(Strike) as Strike, XF.dbo.mbbo(BestBid, BestOffer) as MBBO, ImpliedVolatility
from XFDATA.dbo.OPTION_PRICE_VIEW op
inner join XFDATA.dbo.SECURITY_PRICE sp 
  on sp.SecurityID = op.SecurityID 
  and sp.Date = op.Date
where 
  op.SecurityID = 106276 -- IBM
  and op.Date in (@date1,@date2,@date3)
  and abs(sp.ClosePrice-op.Strike/1000.0) = (
    select min(abs(sp2.ClosePrice - op2.Strike/1000.0)) as Diff
    from XFDATA.dbo.OPTION_PRICE_VIEW op2
	inner join XFDATA.dbo.SECURITY_PRICE sp2 
      on sp2.SecurityID = op2.SecurityID
      and sp2.Date = op2.Date
    where op2.SecurityID = op.SecurityID 
      and op2.Date = op.Date
    group by op2.Date 
   )
order by op.Date
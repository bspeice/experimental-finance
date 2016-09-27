-- CSCO 103042
declare @SecurityID int = 103042

-- Get all relevant data
select op.Date, sp.ClosePrice as StockPrice, op.CallPut, op.Expiration, XF.dbo.formatStrike(op.Strike) as Strike,
                XF.dbo.mbbo(op.BestBid,op.BestOffer) as MBBO, op.ImpliedVolatility, op.OpenInterest, op.Volume
into #data
from XFDATA.dbo.OPTION_PRICE_VIEW op
  inner join XFDATA.dbo.SECURITY_PRICE sp on sp.SecurityID = op.SecurityID and sp.Date = op.Date
where op.SecurityID = @SecurityID
      and op.Date between '2007-1-22' and '2007-1-26'
--and op.CallPut = 'C'

-- Problem 3. Synthetic ATM with 45 days to maturity
-- Check missing dates
select *, datediff(day,Date,Expiration) as DaysToMaturity
into #data3
from #data

-- Closest to ATM with Maturity <= 45 Days
select *
into #P3below
from #data3 d1
where abs(DaysToMaturity - 45) = (
  select min(abs(DaysToMaturity - 45))
  from #data3 d2
  where d1.Date = d2.Date
        and DaysToMaturity <= 45
)
and Strike BETWEEN StockPrice*0.85 and StockPrice*1.11
and DaysToMaturity <= 45

select *
from #P3below

drop table #data, #data3, #P3below
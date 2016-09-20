-- CSCO 103042
declare @SecurityID int = 103042

-- Get all relevant data
select op.Date, sp.ClosePrice as StockPrice, op.CallPut, op.Expiration, XF.dbo.formatStrike(op.Strike) as Strike,
XF.dbo.mbbo(op.BestBid,op.BestOffer) as MBBO, op.ImpliedVolatility, op.OpenInterest, op.Volume
into #data
from XFDATA.dbo.OPTION_PRICE_VIEW op
inner join XFDATA.dbo.SECURITY_PRICE sp on sp.SecurityID = op.SecurityID and sp.Date = op.Date
where op.SecurityID = @SecurityID
and op.Date between '2007-1-1' and '2007-12-31'
and op.CallPut = 'C'

-- Problem 1
-- Extract the 2nd series
select *
into #SecondSeries
from #data d1
where Expiration = (
  select min(Expiration)
  from #data d2
  where d2.Date = d1.Date
  and Expiration > (select min(Expiration) from #data d3 where d3.Date = d1.Date group by Date) 
  group by Date
)

select *, 
  Strike + MBBO - StockPrice as POP,
  Strike/StockPrice as Moneyness
from #SecondSeries
where ImpliedVolatility > 0
and Strike + MBBO - StockPrice > 0.5

-- Problem 2 
-- Extract the 2nd series ATM volatility history
-- ATM is the option with Strike closest to current Stock Price
select identity(int) as ID, Date, ImpliedVolatility
into #SecondSeriesATM
from #SecondSeries s1
where abs(StockPrice - Strike) = (
  select min(abs(StockPrice - Strike))
  from #SecondSeries s2
  where s1.Date = s2.Date
  and s1.Expiration = s2.Expiration
)
order by Date

select *
from #SecondSeriesATM

-- Find biggest changes in volatility
select top 3 Date, ImpliedVolChange
from (
  select s1.Date, s1.ImpliedVolatility, s1.ImpliedVolatility-s2.ImpliedVolatility as ImpliedVolChange
  from #SecondSeriesATM s1
  inner join #SecondSeriesATM s2 on s1.ID-1 = s2.ID
) dat
order by ImpliedVolChange desc


-- Problem 3. Synthetic ATM with 45 days to maturity
-- Check missing dates
select *, datediff(day,Date,Expiration) as DaysToMaturity
into #data3
from #data

-- Closest to ATM with Maturity >= 45 Days
select *
into #P3above
from #data3 d1
where abs(DaysToMaturity - 45) = (
  select min(abs(DaysToMaturity - 45))
  from #data3 d2
  where d1.Date = d2.Date
  and DaysToMaturity >= 45
)
and abs(StockPrice - Strike) = (
  select min(abs(StockPrice - Strike))
  from #data3 d2
  where d1.Date = d2.Date
  and d1.Expiration = d2.Expiration
  and Strike >= StockPrice
)
and DaysToMaturity >= 45
and Strike  >= StockPrice

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
and abs(StockPrice - Strike) = (
  select min(abs(StockPrice - Strike))
  from #data3 d2
  where d1.Date = d2.Date
  and d1.Expiration = d2.Expiration
  and Strike <= StockPrice
)
and DaysToMaturity <= 45
and Strike <= StockPrice

select count(*)
from #P3above

select count(*)
from #P3below

select *
from #P3below
order by DaysToMaturity

select *
from #P3above a
inner join #P3below b on a.Date = b.Date








drop table #data, #SecondSeries, #SecondSeriesATM, #data3, #P3below, #P3above
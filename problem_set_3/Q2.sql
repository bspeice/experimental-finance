-- CSCO 103042
declare @SecurityID int = 103042

-- Get all relevant option data
select op.Date, sp.ClosePrice as StockPrice, op.CallPut, op.Expiration, XF.dbo.formatStrike(op.Strike) as Strike,
  XF.dbo.mbbo(op.BestBid,op.BestOffer) as MBBO, op.ImpliedVolatility, op.OpenInterest, op.Volume
into #data
from XFDATA.dbo.OPTION_PRICE_VIEW op
inner join XFDATA.dbo.SECURITY_PRICE sp on sp.SecurityID = op.SecurityID and sp.Date = op.Date
where op.SecurityID = @SecurityID
  and op.Date between '2007-1-1' and '2007-12-31'

-- Extract the 2nd series
select *,  ROUND(ABS((SIGN(d1.StockPrice-d1.Strike) + 1 ) / 2 * (d1.StockPrice-d1.Strike)),2) as IntrinsicValue
into #SecondSeries
from #data d1
where Expiration = (
  select min(Expiration)
  from #data d2
  where d2.Date = d1.Date
    and Expiration > (select min(Expiration) from #data d3 where d3.Date = d1.Date group by Date)
  group by Date
)

-- Extract the 2nd series ATM volatility history
-- ATM is the option with Strike closest to current Stock Price
-- Call
select identity(int) as ID, Date, CallPut, ImpliedVolatility
into #SecondSeriesATM_C
from #SecondSeries s1
where abs(StockPrice - Strike) = (
  select min(abs(StockPrice - Strike))
  from #SecondSeries s2
  where s1.Date = s2.Date
    and s1.Expiration = s2.Expiration
	and CallPut = 'C'
)
and CallPut = 'C'
order by Date
-- Put
select identity(int) as ID, Date, CallPut, ImpliedVolatility
into #SecondSeriesATM_P
from #SecondSeries s1
where abs(StockPrice - Strike) = (
  select min(abs(StockPrice - Strike))
  from #SecondSeries s2
  where s1.Date = s2.Date
    and s1.Expiration = s2.Expiration
	and CallPut = 'P'
)
and CallPut = 'P'
order by Date

-- Find 3 biggest (absolute) changes in volatility for call and put
select Date, CallPut, ImpliedVolChange
from (
  select top 3 s1.Date, s1.CallPut, s1.ImpliedVolatility, s1.ImpliedVolatility-s2.ImpliedVolatility as ImpliedVolChange
  from #SecondSeriesATM_C s1
  inner join #SecondSeriesATM_C s2 on s1.ID-1 = s2.ID
  order by abs(s1.ImpliedVolatility-s2.ImpliedVolatility) desc
) dat
union
select Date, CallPut, ImpliedVolChange
from (
  select top 3 s1.Date, s1.CallPut, s1.ImpliedVolatility, s1.ImpliedVolatility-s2.ImpliedVolatility as ImpliedVolChange
  from #SecondSeriesATM_P s1
  inner join #SecondSeriesATM_P s2 on s1.ID-1 = s2.ID
  order by abs(s1.ImpliedVolatility-s2.ImpliedVolatility) desc
) dat
order by CallPut, Date

drop table #data, #SecondSeries, #SecondSeriesATM_C, #SecondSeriesATM_P
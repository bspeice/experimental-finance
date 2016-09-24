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

select *,
  MBBO - IntrinsicValue as POP,
  Strike/StockPrice as Moneyness
from #SecondSeries
where ImpliedVolatility > 0
      and MBBO - IntrinsicValue > 0.5
ORDER BY Date

drop table #data, #SecondSeries

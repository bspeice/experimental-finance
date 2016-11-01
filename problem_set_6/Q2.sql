declare @Ticker varchar(10) = 'KKD'
declare @SecurityID int = (select SecurityID from XFDATA.dbo.SECURITY where ticker = @Ticker)
declare @StartDate datetime = '2004-2-1'
declare @EndDate datetime = '2004-8-31'

select op.Date, sp.ClosePrice as StockPrice, XF.dbo.formatStrike(Strike) as Strike, 
Expiration, datediff(day,op.Date,Expiration) as ExpirationD,
CallPut, XF.dbo.mbbo(BestBid,BestOffer) as MBBO, ImpliedVolatility,
XF.db_datawriter.InterpolateRate(datediff(day,op.Date,Expiration), op.Date)/100.0 as Rate
into #data
from XFDATA.dbo.OPTION_PRICE_VIEW op
join XFDATA.dbo.SECURITY_PRICE sp on op.Date = sp.Date and op.SecurityID = sp.SecurityID
where op.SecurityID = @SecurityID
and op.Date between @StartDate and @EndDate

select *
into #call_atm
from #data d
where abs(Strike-StockPrice) = (select min(abs(Strike-StockPrice)) from #data where Date = d.Date)
and ImpliedVolatility > 0
and CallPut = 'C'
order by Date

select *
into #put_atm
from #data d
where abs(Strike-StockPrice) = (select min(abs(Strike-StockPrice)) from #data where Date = d.Date)
and ImpliedVolatility > 0
and CallPut = 'P'
order by Date

select *
into #c
from #call_atm a
where abs(ExpirationD-75) = (select min(abs(ExpirationD-75)) from #call_atm where Date = a.Date)

select *
into #p
from #put_atm a
where abs(ExpirationD-75) = (select min(abs(ExpirationD-75)) from #put_atm where Date = a.Date)


select c.Date, c.StockPrice, c.Strike, c.ExpirationD, c.ExpirationD/360.0 as Maturity, 
c.MBBO as CallPrice, p.MBBO as PutPrice, 
c.ImpliedVolatility as cIV, p.ImpliedVolatility as pIV, c.Rate,
c.MBBO + case when c.StockPrice > c.Strike then c.StockPrice - c.Strike else 0 end as Cpop,
p.MBBO + case when c.StockPrice < c.Strike then c.Strike - c.StockPrice else 0 end as Ppop
into #res
from #c c
join #p p on c.Date = p.Date and c.Strike = p.Strike and c.Expiration = p.Expiration

select *,
-(Cpop - Ppop - Rate*Maturity*Strike) / (StockPrice * Maturity)
from #res

drop table #data, #call_atm, #put_atm, #c, #p, #res
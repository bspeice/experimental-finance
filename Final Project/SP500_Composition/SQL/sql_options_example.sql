declare @Front datetime = (select min(Expiration) from XF.db_datawriter.hi2179_SP500_comp_options)
declare @ATMStrike float = (
select distinct Strike
from XF.db_datawriter.hi2179_SP500_comp_options co
where abs(Moneyness-1) = (
select min(abs(Moneyness-1))
from XF.db_datawriter.hi2179_SP500_comp_options
where Expiration = @Front) 
and Expiration = @Front)

select op.Date, 
	sp.ClosePrice as StockPrice,
    case when op.Date = co.AnnouncementDate then 1 else 0 end as IsAnnouncementDate,
    case when op.Date = co.ChangeDate then 1 else 0 end as IsChangeDate,
    year(co.AnnouncementDate) as Year,
	dbo.formatStrike(op.Strike) as Strike,
	op.Expiration,
	op.CallPut,
	op.BestBid,
	op.BestOffer,
	(convert(float,op.BestBid)+convert(float,op.BestOffer))/2.0 as MBBO,
	op.ImpliedVolatility,
	op.Delta,
	op.Volume,
	op.OpenInterest,
	datediff(day,op.Date,op.Expiration) as TTE_D,
    inSecurityID as SecurityID,
    inTicker as Ticker,
    inName as Name,
    inSector as Sector,
    AnnouncementDate,
    ChangeDate,
    co.ID as DataID
from XFDATA.dbo.OPTION_PRICE_VIEW op
join XFDATA.dbo.SECURITY_PRICE sp on op.SecurityID = sp.SecurityID and op.Date = sp.Date
join XF.db_datawriter.hi2179_SP500_comp co on op.SecurityID = co.inSecurityID
    and abs(datediff(day,op.Date,co.AnnouncementDate)) <= 35
    and abs(datediff(day,op.Date,co.ChangeDate)) <= 35
where Expiration = @Front
and Strike = @ATMStrike
and co.ID = 448
order by op.CallPut, co.AnnouncementDate, co.inTicker, op.Date

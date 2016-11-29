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
	and op.Expiration > co.ChangeDate
    and abs(datediff(day,op.Date,co.AnnouncementDate)) <= 35
    and abs(datediff(day,op.Date,co.ChangeDate)) <= 35
	and ((op.Delta between 0.45 and 0.55) or (op.delta between -0.45 and -0.55))
	and op.ImpliedVolatility > 0
	and op.BestBid > 0
	and co.ID between 300 and 305
order by co.AnnouncementDate, co.inTicker, op.Date
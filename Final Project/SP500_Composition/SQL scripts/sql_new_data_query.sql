declare @datediff int = 30
select sp.Date, 
    case when sp.Date = co.AnnouncementDate then 1 else 0 end as IsAnnouncementDate,
    case when sp.Date = co.ChangeDate then 1 else 0 end as IsChangeDate,
    year(co.AnnouncementDate) as Year,
    sp.PriceLow, 
    sp.PriceHigh, 
    sp.PriceOpen,
    sp.PriceClose,
    sp.PriceOpen * sp.AdjustmentFactor / (select max(AdjustmentFactor) from XFDATA.dbo.SECURITY_PRICE where SecurityID = sp.SecurityID) as AdjS_OpenPrice,
    sp.PriceClose * sp.AdjustmentFactor / (select max(AdjustmentFactor) from XFDATA.dbo.SECURITY_PRICE where SecurityID = sp.SecurityID) as AdjS_ClosePrice,
    sp.Volume,
    sp.TotalReturn,
    sp.AdjustmentFactor,
    sp.SharesOutstanding,
    sp.SharesOutstanding * sp.PriceClose /1e3 as MarketCapB,
    inSecurityID as SecurityID,
    inTicker as Ticker,
    inName as Name,
    inSector as Sector,
    AnnouncementDate,
    ChangeDate,
    co.ID as DataID,
    spy.PriceOpen as IDX_Open,
    spy.PriceClose as IDX_Close,
    spy.PriceOpen * spy.AdjustmentFactor / (select max(AdjustmentFactor) from XF.db_datawriter.hi2179_SP500_comp_2_SecData where SecurityID = spy.SecurityID) as IDX_AdjSD_Open,
    spy.PriceClose * spy.AdjustmentFactor / (select max(AdjustmentFactor) from XF.db_datawriter.hi2179_SP500_comp_2_SecData where SecurityID = spy.SecurityID) as IDX_AdjSD_Close,
    spy.SharesOutstanding as IDX_SharesOutstanding,
    spy.SharesOutstanding * spy.PriceClose as IDX_MarketCap,
    spy.TotalReturn as IDX_Return
from XF.db_datawriter.hi2179_SP500_comp_2_SecData sp
join XF.db_datawriter.hi2179_SP500_comp_2 co on sp.SecurityID = co.inSecurityID 
    and (abs(datediff(day,sp.Date,co.AnnouncementDate)) <= @datediff or abs(datediff(day,sp.Date,co.ChangeDate)) <= @datediff)
join XF.db_datawriter.hi2179_SP500_comp_2_SecData spy on spy.SecurityID = 154402 and spy.Date = sp.Date
order by co.AnnouncementDate, co.inTicker, sp.Date
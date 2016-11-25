declare @datediff int = 30 --'{date_diff}'
select
	co.ID as DataID,
	spy.Date, 
	AnnouncementDate,
    ChangeDate,
    -- Joining
	inSecurityID as In_SecurityID,
    inTicker as In_Ticker,
    inName as In_Name,
    inSector as In_Sector,
	sp_in.BidLow as In_LowPrice,
	sp_in.AskHigh as In_HighPrice,
    sp_in.OpenPrice as In_OpenPrice,
    sp_in.ClosePrice as In_ClosePrice,
    sp_in.OpenPrice * sp_in.AdjustmentFactor2 / (select max(AdjustmentFactor2) from XFDATA.dbo.SECURITY_PRICE where SecurityID = sp_in.SecurityID) as In_OpenPrice_Adj,
    sp_in.ClosePrice * sp_in.AdjustmentFactor2 / (select max(AdjustmentFactor2) from XFDATA.dbo.SECURITY_PRICE where SecurityID = sp_in.SecurityID) as In_ClosePrice_Adj,
	sp_in.Volume as In_Volume,
    sp_in.AdjustmentFactor2 as In_AdjustmentFactor,
    sp_in.SharesOutstanding as  In_SharesOutstanding,
    sp_in.SharesOutstanding * sp_in.ClosePrice /1e3 as In_MarketCap_B,
	-- Joining options
	oivol_in.Call_OI as In_Call_OI,
    oivol_in.Put_OI as In_Put_OI,
    oivol_in.OI as In_Option_OI,
    oivol_in.Call_Volume as In_Call_Volume,
    oivol_in.Put_Volume as In_Put_Volume,
    oivol_in.Volume as In_Option_Vol,	
	-- Leaving
	outSecurityID as Out_SecurityID,
    outTicker as Out_Ticker,
    outName as Out_Name,
    outSector as Out_Sector,
	sp_out.BidLow as Out_LowPrice,
	sp_out.AskHigh as Out_HighPrice,
    sp_out.OpenPrice as Out_OpenPrice,
    sp_out.ClosePrice as Out_ClosePrice,
    sp_out.OpenPrice * sp_out.AdjustmentFactor2 / (select max(AdjustmentFactor2) from XFDATA.dbo.SECURITY_PRICE where SecurityID = sp_out.SecurityID) as Out_OpenPrice_Adj,
    sp_out.ClosePrice * sp_out.AdjustmentFactor2 / (select max(AdjustmentFactor2) from XFDATA.dbo.SECURITY_PRICE where SecurityID = sp_out.SecurityID) as Out_ClosePrice_Adj,
	sp_out.Volume as Out_Volume,
    sp_out.AdjustmentFactor2 as Out_AdjustmentFactor,
    sp_out.SharesOutstanding as  Out_SharesOutstanding,
    sp_out.SharesOutstanding * sp_out.ClosePrice /1e3 as Out_MarketCap_B,
	-- Leaving options
	oivol_out.Call_OI as Out_Call_OI,
    oivol_out.Put_OI as Out_Put_OI,
    oivol_out.OI as Out_Option_OI,
    oivol_out.Call_Volume as Out_Call_Volume,
    oivol_out.Put_Volume as Out_Put_Volume,
    oivol_out.Volume as Out_Option_Vols,
	-- Index
    spy.OpenPrice as IDX_OpenPrice,
    spy.ClosePrice as IDX_ClosePrice,
    spy.OpenPrice * spy.AdjustmentFactor2 / (select max(AdjustmentFactor2) from XFDATA.dbo.SECURITY_PRICE where SecurityID = spy.SecurityID) as IDX_OpenPrice_Adj,
    spy.ClosePrice * spy.AdjustmentFactor2 / (select max(AdjustmentFactor2) from XFDATA.dbo.SECURITY_PRICE where SecurityID = spy.SecurityID) as IDX_ClosePrice_Adj,
	-- 
	case when spy.Date = co.AnnouncementDate then 1 else 0 end as IsAnnouncementDate,
    case when spy.Date = co.ChangeDate then 1 else 0 end as IsChangeDate,
	co.IsTakeover,
    year(co.AnnouncementDate) as Year
into #temp
from XF.db_datawriter.hi2179_SP500_comp co
join XFData.dbo.SECURITY_PRICE spy on spy.SecurityID = 109820
  and (abs(datediff(day,spy.Date,co.AnnouncementDate)) <= @datediff or abs(datediff(day,spy.Date,co.ChangeDate)) <= @datediff)
left join XFDATA.dbo.SECURITY_PRICE sp_in on sp_in.SecurityID = co.inSecurityID and sp_in.Date = spy.Date
left join XF.db_datawriter.hi2179_OIVOL oivol_in on oivol_in.SecurityID = sp_in.SecurityID and oivol_in.Date = sp_in.Date
left join XFDATA.dbo.SECURITY_PRICE sp_out on sp_out.SecurityID = co.outSecurityID and sp_out.Date = spy.Date
left join XF.db_datawriter.hi2179_OIVOL oivol_out on oivol_out.SecurityID = sp_out.SecurityID and oivol_out.Date = sp_out.Date
order by co.ID, spy.Date

-- Check dates
select *,
(select min(date) from #temp where DataID = t.DataID and In_ClosePrice is not null) as MinInDate,
(select min(date) from #temp where DataID = t.DataID and Out_ClosePrice is not null) as MinOutDate,
(select max(date) from #temp where DataID = t.DataID and In_ClosePrice is not null) as MaxInDate,
(select max(date) from #temp where DataID = t.DataID and Out_ClosePrice is not null) as MaxOutDate
into #temp2
from #temp t

-- Check tradability
select *,
case when MinInDate <= AnnouncementDate and MaxInDate >= ChangeDate then 1 else 0 end as IsTradable,
case when MinInDate < AnnouncementDate and MaxInDate > ChangeDate 
	 and MinOutDate < AnnouncementDate and MaxOutDate > ChangeDate 
	 and IsTakeover = 0 then 1 else 0 end as IsPairTradable
from #temp2

drop table #temp,#temp2
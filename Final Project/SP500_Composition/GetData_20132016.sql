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
	sp_in.PriceLow as In_LowPrice,
	sp_in.PriceHigh as In_HighPrice,
    sp_in.PriceOpen as In_OpenPrice,
    sp_in.PriceClose as In_ClosePrice,
    sp_in.PriceOpen * sp_in.AdjustmentFactor / (select max(AdjustmentFactor) from XF.db_datawriter.hi2179_SP500_comp_2_SecData where SecurityID = sp_in.SecurityID) as In_OpenPrice_Adj,
    sp_in.PriceClose * sp_in.AdjustmentFactor / (select max(AdjustmentFactor) from XF.db_datawriter.hi2179_SP500_comp_2_SecData where SecurityID = sp_in.SecurityID) as In_ClosePrice_Adj,
	sp_in.Volume as In_Volume,
    sp_in.AdjustmentFactor as In_AdjustmentFactor,
    sp_in.SharesOutstanding as  In_SharesOutstanding,
    sp_in.SharesOutstanding * sp_in.PriceClose /1e3 as In_MarketCap_B,
	-- Leaving
	outSecurityID as Out_SecurityID,
    outTicker as Out_Ticker,
    outName as Out_Name,
    outSector as Out_Sector,
	sp_out.PriceLow as Out_LowPrice,
	sp_out.PriceHigh as Out_HighPrice,
    sp_out.PriceOpen as Out_OpenPrice,
    sp_out.PriceClose as Out_ClosePrice,
    sp_out.PriceOpen * sp_out.AdjustmentFactor / (select max(AdjustmentFactor) from XF.db_datawriter.hi2179_SP500_comp_2_SecData where SecurityID = sp_out.SecurityID) as Out_OpenPrice_Adj,
    sp_out.PriceClose * sp_out.AdjustmentFactor / (select max(AdjustmentFactor) from XF.db_datawriter.hi2179_SP500_comp_2_SecData where SecurityID = sp_out.SecurityID) as Out_ClosePrice_Adj,
	sp_out.Volume as Out_Volume,
    sp_out.AdjustmentFactor as Out_AdjustmentFactor,
    sp_out.SharesOutstanding as  Out_SharesOutstanding,
    sp_out.SharesOutstanding * sp_out.PriceClose /1e3 as Out_MarketCap_B,
	-- Index
    spy.PriceOpen as IDX_OpenPrice,
    spy.PriceClose as IDX_ClosePrice,
    spy.PriceOpen * spy.AdjustmentFactor / (select max(AdjustmentFactor) from XF.db_datawriter.hi2179_SP500_comp_2_SecData where SecurityID = spy.SecurityID) as IDX_OpenPrice_Adj,
    spy.PriceClose * spy.AdjustmentFactor / (select max(AdjustmentFactor) from XF.db_datawriter.hi2179_SP500_comp_2_SecData where SecurityID = spy.SecurityID) as IDX_ClosePrice_Adj,
	-- 
	case when spy.Date = co.AnnouncementDate then 1 else 0 end as IsAnnouncementDate,
    case when spy.Date = co.ChangeDate then 1 else 0 end as IsChangeDate,
	co.IsTakeover,
    year(co.AnnouncementDate) as Year
into #temp
from XF.db_datawriter.hi2179_SP500_comp_2 co
join XF.db_datawriter.hi2179_SP500_comp_2_SecData spy on spy.SecurityID = 109820
  and (abs(datediff(day,spy.Date,co.AnnouncementDate)) <= @datediff or abs(datediff(day,spy.Date,co.ChangeDate)) <= @datediff)
left join XF.db_datawriter.hi2179_SP500_comp_2_SecData sp_in on sp_in.SecurityID = co.inSecurityID and sp_in.Date = spy.Date
left join XF.db_datawriter.hi2179_SP500_comp_2_SecData sp_out on sp_out.SecurityID = co.outSecurityID and sp_out.Date = spy.Date
where isnull(sp_in.ClosePrice,1) > 0 and isnull(sp_in.OpenPrice,1) > 0 and isnull(sp_out.ClosePrice,1) > 0 and isnull(sp_out.OpenPrice,1) > 0
order by co.ID, spy.Date

delete from #temp where DataID = 307 and Date = '2006-7-18' -- buggy price

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

drop table #temp,#temp2
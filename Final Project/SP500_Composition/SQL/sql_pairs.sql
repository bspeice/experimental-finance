declare @datediff int = 30

select co.ID as DataID,
  sp_in.Date,
  case when sp_in.Date = co.AnnouncementDate then 1 else 0 end as IsAnnouncementDate,
  case when sp_in.Date = co.ChangeDate then 1 else 0 end as IsChangeDate,
  year(co.AnnouncementDate) as Year,
  AnnouncementDate,
  ChangeDate,
  sp_in.OpenPrice as In_OpenPrice,
  sp_in.ClosePrice In_ClosePrice,
  sp_in.OpenPrice * sp_in.AdjustmentFactor2 / (select max(AdjustmentFactor2) from XFDATA.dbo.SECURITY_PRICE where SecurityID = sp_in.SecurityID) as In_AdjSD_OpenPrice,
  sp_in.ClosePrice * sp_in.AdjustmentFactor2 / (select max(AdjustmentFactor2) from XFDATA.dbo.SECURITY_PRICE where SecurityID = sp_in.SecurityID) as In_AdjSD_ClosePrice,
  sp_in.Volume as In_Volume,
  sp_in.AdjustmentFactor as In_Adj, 
  sp_in.AdjustmentFactor2 as In_Adj2,
  inSecurityID as In_SecurityID,
  inTicker as In_Ticker,
  inName as In_Name,
  inSector as In_Sector,
  sp_out.OpenPrice as Out_OpenPrice,
  sp_out.ClosePrice Out_ClosePrice,
  sp_out.OpenPrice * sp_out.AdjustmentFactor2 / (select max(AdjustmentFactor2) from XFDATA.dbo.SECURITY_PRICE where SecurityID = sp_out.SecurityID) as Out_AdjSD_OpenPrice,
  sp_out.ClosePrice * sp_out.AdjustmentFactor2 / (select max(AdjustmentFactor2) from XFDATA.dbo.SECURITY_PRICE where SecurityID = sp_out.SecurityID) as Out_AdjSD_ClosePrice,
  sp_out.Volume as Out_Volume,
  sp_out.AdjustmentFactor as Out_Adj, 
  sp_out.AdjustmentFactor2 as Out_Adj2,
  outSecurityID as Out_SecurityID,
  outTicker as Out_Ticker,
  outName as Out_Name,
  outSector as Out_Sector
from XF.db_datawriter.hi2179_SP500_comp co
join XFDATA.dbo.SECURITY_PRICE sp_out on sp_out.SecurityID = co.inSecurityID
  and (abs(datediff(day,sp_out.Date,co.AnnouncementDate)) <= @datediff or abs(datediff(day,sp_out.Date,co.ChangeDate)) <= @datediff)
join XFDATA.dbo.SECURITY_PRICE sp_in on sp_in.SecurityID = co.inSecurityID
  and (abs(datediff(day,sp_in.Date,co.AnnouncementDate)) <= @datediff or abs(datediff(day,sp_in.Date,co.ChangeDate)) <= @datediff)    
where sp_in.Date = sp_out.Date 
and co.IsTakeover = 0
order by co.AnnouncementDate, sp_in.Date




    


   
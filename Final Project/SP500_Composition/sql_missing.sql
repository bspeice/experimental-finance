select  
  co.ID as DataID,
  inSecurityID as SecurityID,
  inTicker as Ticker,
  inName as Name,
  inSector as Sector,
  AnnouncementDate,
  ChangeDate,
  min(sp.Date),
  max(sp.Date)
from XFDATA.dbo.SECURITY_PRICE sp
right join XF.db_datawriter.hi2179_SP500_comp co on sp.SecurityID = co.inSecurityID 
where co.inTicker <> '-' and sp.Date is null
group by 
co.ID ,
  inSecurityID ,
  inTicker ,
  inName ,
  inSector ,
  AnnouncementDate,
  ChangeDate
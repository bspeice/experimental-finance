select co.ID, co.inSecurityId, co.inTicker, co.inName, co.IsTakeover, sp.SecurityID, count(*)
from XF.db_datawriter.hi2179_SP500_comp_2 co
left join XF.db_datawriter.hi2179_SP500_comp_2_SecData sp 
on co.inSecurityID = sp.SecurityID and sp.Date = co.AnnouncementDate
where sp.SecurityID is null 
group by co.ID, co.inSecurityId, co.inTicker, sp.SecurityID, co.inName, co.IsTakeover
order by 1


select co.ID, co.inSecurityId, co.inTicker, co.inName, sp.SecurityID, co.IsTakeover, count(*)
from XF.db_datawriter.hi2179_SP500_comp_2 co
left join XF.db_datawriter.hi2179_SP500_comp_2_SecData sp 
on co.inSecurityID = sp.SecurityID and sp.Date = co.ChangeDate
where sp.SecurityID is null 
group by co.ID, co.inSecurityId, co.inTicker, sp.SecurityID, co.inName, co.IsTakeover
order by 1


select co.ID, co.outSecurityId, co.outTicker, co.outName, sp.SecurityID, co.IsTakeover, count(*)
from XF.db_datawriter.hi2179_SP500_comp_2 co
left join XF.db_datawriter.hi2179_SP500_comp_2_SecData sp 
on co.outSecurityID = sp.SecurityID and sp.Date = co.AnnouncementDate
where sp.SecurityID is null 
group by co.ID, co.outSecurityId, co.outTicker, sp.SecurityID, co.outName, co.IsTakeover
order by 1


select co.ID, co.outSecurityId, co.outTicker, co.outName, sp.SecurityID, co.IsTakeover, count(*)
from XF.db_datawriter.hi2179_SP500_comp_2 co
left join XF.db_datawriter.hi2179_SP500_comp_2_SecData sp 
on co.outSecurityID = sp.SecurityID and sp.Date = co.ChangeDate
where sp.SecurityID is null 
group by co.ID, co.outSecurityId, co.outTicker, sp.SecurityID, co.outName, co.IsTakeover
order by 1
select 
op.SecurityID,
op.Date, 
sum(case when op.CallPut = 'C' then op.OpenInterest else 0 end) as Call_OI,
sum(case when op.CallPut = 'P' then op.OpenInterest else 0 end) as Put_OI,
sum(op.OpenInterest) as OI, 
sum(case when op.CallPut = 'C' then op.Volume else 0 end) as Call_Volume,
sum(case when op.CallPut = 'P' then op.Volume else 0 end) as Put_Volume,
sum(op.Volume) as Volume
into #temp
from XF.db_datawriter.hi2179_SP500_comp  co
join XFDATA.dbo.OPTION_PRICE_VIEW op on co.inSecurityID = op.SecurityID
  and abs(datediff(day,op.Date,co.AnnouncementDate)) <= 350
group by SecurityID, Date



select *
into XF.db_datawriter.hi2179_OIVOL
from #temp
order by SecurityID, Date


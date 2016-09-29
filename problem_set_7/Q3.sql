declare @ticker varchar = 'CEPH' 

select Date, OpenPrice, AskHigh, BidLow, ClosePrice, Volume, AdjustmentFactor, AdjustmentFactor2
from XFDATA.dbo.SECURITY_PRICE sp
inner join XFDATA.dbo.SECURITY s on sp.SecurityID = s.SecurityID
where s.Ticker = @ticker
and sp.Date between '2011-1-1' and '2011-5-31'

--select *
--from XFDATA.dbo.DISTRIBUTION
--where SecurityID = (select SecurityID from XFDATA.dbo.SECURITY where Ticker = @ticker)
--and RecordDate between '2011-1-1' and '2011-5-31'

-- Distribution Type 
-- 1 Div, 2 Split 
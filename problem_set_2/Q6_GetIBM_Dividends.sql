-- IBM 106276
select ExDate, Amount
from XFDATA.dbo.DISTRIBUTION
where SecurityID = 106276
and DistributionType = '1'
and Amount > 0
declare @date1 date = '2013-2-13'
declare @date2 date = '2013-4-16'
declare @date3 date = '2013-7-10'
--declare @date1 date = '2006-2-8'
--declare @date2 date = '2006-4-12'
--declare @date3 date = '2006-7-10'

select Date, Days, Rate
from XFDATA.dbo.ZERO_CURVE
where Date in (@date1,@date2,@date3)
and Days < 1000
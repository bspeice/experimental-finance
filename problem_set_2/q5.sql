select 
  sum(case when ImpliedVolatility < 0 then 1 else 0 end) as BadCount, 
  count(*) as TotalCount,
  convert(float,sum(case when ImpliedVolatility < 0 then 1 else 0 end)) / count(*) as BadProportion
from XFDATA.dbo.OPTION_PRICE_VIEW
where 
  SecurityID = 106276 -- IBM
  and date between '2010-1-1' and '2013-12-31'
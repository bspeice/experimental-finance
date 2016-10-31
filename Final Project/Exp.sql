-- Parameters are set externally
declare @Ticker varchar(10) = '{ticker}'
declare @SecurityID int = (select SecurityID from XFDATA.dbo.SECURITY where Ticker = @Ticker)
declare @EventDate datetime = '{event_date}'  -- yyyy-MM-dd

select top 1 Expiration --Selecting closest expiration
from XFDATA.dbo.OPTION_PRICE_VIEW
where SecurityID = @SecurityID and Date=@EventDate
      AND SpecialSettlement=0 --Eliminate Mini Options
GROUP BY Expiration
ORDER BY Expiration
union
select top 1 Expiration --Selecting third Friday of the month closest expiration
from XFDATA.dbo.OPTION_PRICE_VIEW
where SecurityID = @SecurityID and Date=@EventDate
      and datepart(day, Expiration)>=15
      and datepart(day, Expiration)<=(CASE WHEN DATEPART(WEEKDAY,Expiration)=7 THEN 22 ELSE 21 END)
      AND SpecialSettlement=0 --Eliminate Mini Options
GROUP BY Expiration
ORDER BY Expiration


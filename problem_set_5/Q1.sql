declare @Ticker varchar(10) = 'CSCO' 
declare @SecurityID int = (select SecurityID from XFDATA.dbo.SECURITY where Ticker = @Ticker)

create table #Earnings(EarningDate datetime, First datetime, Second datetime, JanLeap datetime)

insert into #Earnings
values
('2011-8-10',null,null,null),
('2011-11-9',null,null,null),
('2012-2-8',null,null,null),
('2012-5-9',null,null,null),
('2012-8-15',null,null,null),
('2012-11-13',null,null,null),
('2013-2-13',null,null,null),
('2013-5-15',null,null,null)

select distinct Expiration
into #Expirations
from XFDATA.dbo.OPTION_PRICE_VIEW
where SecurityID = @SecurityID

update e set 
[First] = (select min(Expiration) from #Expirations where Expiration > e.EarningDate),
[Second] = (select min(Expiration) from #Expirations where Expiration > e.EarningDate and Expiration > (select min(Expiration) from #Expirations where Expiration > e.EarningDate)),
JanLeap = (select min(Expiration) from #Expirations where Expiration > e.EarningDate and datediff(month,e.EarningDate,Expiration) > 5 and month(Expiration) = 1)
from #Earnings e

select * from #Earnings

drop table #Earnings, #Expirations

-- AAPL
--('2011-7-19',null,null,null),
--('2011-10-18',null,null,null),
--('2012-1-24',null,null,null),
--('2012-4-24',null,null,null),
--('2012-7-24',null,null,null),
--('2012-10-25',null,null,null),
--('2013-1-23',null,null,null),
--('2013-4-23',null,null,null)
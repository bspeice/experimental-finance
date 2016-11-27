--drop table XF.db_datawriter.hi2179_SP500_comp_options

create table XF.db_datawriter.hi2179_SP500_comp_options
(
ID int identity(1,1),
CompID int,
SecurityID int,
CallPut char(1),
Strike bigint,
Expiration datetime,
Delta float,
Moneyness float,
OptionID int,
Name varchar(250),
CONSTRAINT fk_comp FOREIGN KEY (CompID) references XF.db_datawriter.hi2179_SP500_comp(ID)
)

-- Entering
insert into XF.db_datawriter.hi2179_SP500_comp_options
select distinct 
co.ID,
op.SecurityID, 
CallPut, 
Strike as Strike,
Expiration as Expiration, 
op.Delta,
dbo.formatStrike(Strike)/sp.ClosePrice as Moneyness,
op.OptionID,
co.inTicker + '_' + 
	convert(varchar,op.SecurityID) + '_' + 
	CallPut + '_' + 
	convert(varchar,convert(date,Expiration)) + '_' + 
	convert(varchar,dbo.formatStrike(Strike)) as Name
from hi2179_SP500_comp co
join XFDATA.dbo.OPTION_PRICE_VIEW op on co.inSecurityID = op.SecurityID and op.Date = co.AnnouncementDate
join XFDATA.dbo.SECURITY_PRICE sp on sp.SecurityID = op.SecurityID and sp.Date = op.Date
where op.Expiration > co.ChangeDate
and op.SpecialSettlement = 0



-- Exiting
insert into XF.db_datawriter.hi2179_SP500_comp_options
select distinct 
co.ID,
op.SecurityID, 
CallPut, 
Strike as Strike,
Expiration as Expiration, 
op.Delta,
dbo.formatStrike(Strike)/sp.ClosePrice as Moneyness,
op.OptionID,
co.inTicker + '_' + 
	convert(varchar,op.SecurityID) + '_' + 
	CallPut + '_' + 
	convert(varchar,convert(date,Expiration)) + '_' + 
	convert(varchar,dbo.formatStrike(Strike)) as Name
from hi2179_SP500_comp co
join XFDATA.dbo.OPTION_PRICE_VIEW op on co.outSecurityID = op.SecurityID and op.Date = co.AnnouncementDate
join XFDATA.dbo.SECURITY_PRICE sp on sp.SecurityID = op.SecurityID and sp.Date = op.Date
where op.Expiration > co.ChangeDate
and op.SpecialSettlement = 0
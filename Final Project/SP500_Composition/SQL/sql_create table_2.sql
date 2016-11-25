drop table XF.db_datawriter.hi2179_SP500_comp_2 

create table XF.db_datawriter.hi2179_SP500_comp_2
(
ID int identity(1,1) primary key,
AnnouncementDate datetime,
ChangeDate datetime,
inName varchar(250),
inTicker varchar(250),
inSector varchar(250),
inPrevNameTicker varchar(250),
inSecurityID int,
inIssuerDesc varchar(250),
outName varchar(250),
outTicker varchar(250),
outSector varchar(250),
outPrevNameTicker varchar(250),
outSecurityID int,
outIssuerDesc varchar(250),
IsTakeover int
)

insert into XF.db_datawriter.hi2179_SP500_comp_2
select AnnouncementDate, ChangeDate, inName,	inTicker,	inSector,	inPrevNameTicker,	inSecurityID,	inIssuerDesc,	outName,	outTicker,	outSector,	outPrevNameTicker,	outSecurityID,	outIssuerDesc, IsTakeover
from XF.db_datawriter.hi2179_SP500_comp_temp_2
order by [index]

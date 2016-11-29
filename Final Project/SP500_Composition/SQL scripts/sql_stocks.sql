select Date, 
      case when sp.Date = co.AnnouncementDate then 1 else 0 end as IsAnnouncementDate,
      case when sp.Date = co.ChangeDate then 1 else 0 end as IsChangeDate,
      year(co.AnnouncementDate) as Year,
      BidLow, 
      AskHigh, 
      OpenPrice,
      ClosePrice,
      OpenPrice * AdjustmentFactor2 as Adj_OpenPrice,
      ClosePrice * AdjustmentFactor2 as Adj_ClosePrice,
      Volume,
      TotalReturn,
      AdjustmentFactor,
      AdjustmentFactor2,
      inSecurityID as SecurityID,
      inTicker as Ticker,
      inName as Name,
      inSector as Sector,
      AnnouncementDate,
      ChangeDate,
      co.ID as DataID
    from XFDATA.dbo.SECURITY_PRICE sp
    join XF.db_datawriter.hi2179_SP500_comp co on sp.SecurityID = co.inSecurityID 
      and abs(datediff(day,sp.Date,co.AnnouncementDate)) <= 35
      and abs(datediff(day,sp.Date,co.ChangeDate)) <= 35
    order by co.AnnouncementDate, co.inTicker, sp.Date
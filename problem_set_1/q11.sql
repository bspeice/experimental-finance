SELECT COUNT(*) as Prices, MIN(op.Date) as WeekStart
FROM XFDATA.dbo.OPTION_PRICE_1996_09 op
GROUP BY DATEPART(WEEK, op.Date), DATEPART(YEAR, op.Date)
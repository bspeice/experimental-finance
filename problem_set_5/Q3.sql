/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [XFDATA].[dbo].[lv_options_trades]
  where symbol = 'GOOG'
  order by tradeSize desc
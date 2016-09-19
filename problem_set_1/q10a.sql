SELECT
  CONVERT(FLOAT, op.Strike) / 1000 as Strike,
  DATEDIFF(DAY, '2008-03-03', op.Expiration) as Expiration,
  op.ImpliedVolatility

FROM XFDATA.dbo.SECURITY s
  INNER JOIN XFDATA.dbo.OPTION_PRICE_2008_03 op on s.SecurityID = op.SecurityID

WHERE s.Ticker = 'PG'
  AND op.ImpliedVolatility > 0
  AND op.ImpliedVolatility is not NULL
  AND op.CallPut = 'C'
  AND op.Date = '2008-03-03'
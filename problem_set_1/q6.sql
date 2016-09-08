SELECT CONVERT(FLOAT, op.Strike) / 1000 as Strike,
  op.Expiration,
  op.CallPut
FROM XFDATA.dbo.SECURITY s
  INNER JOIN XFDATA.dbo.OPTION_PRICE_2012_08 op ON s.SecurityID = op.SecurityID
WHERE s.Ticker = 'KO'
GROUP BY
  op.Expiration,
  op.CallPut,
  op.Strike

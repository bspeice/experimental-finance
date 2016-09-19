SELECT COUNT(sub.is_valid) as total_valid,
  CONVERT(FLOAT, SUM(sub.is_valid)) / COUNT(sub.is_valid) as pct_valid,
  1 - CONVERT(FLOAT, SUM(sub.is_valid)) / COUNT(sub.is_valid) as pct_invalid

FROM (
  SELECT CASE WHEN (
    op.ImpliedVolatility > 0
    and op.ImpliedVolatility < 1
    -- I'm adding this for thoroughness, but it's technically redundant
    and op.ImpliedVolatility is not NULL
  ) THEN 1
    ELSE 0 END AS is_valid
  FROM XFDATA.dbo.SECURITY s
    INNER JOIN XFDATA.dbo.OPTION_PRICE_VIEW op ON s.SecurityID = op.SecurityID

  WHERE s.Ticker = 'IBM'
        AND op.Date BETWEEN '2010-01-01' AND '2013-01-01'
) sub
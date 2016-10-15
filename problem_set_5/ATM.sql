-- Parameters are set externally
declare @Ticker varchar(10) = '{ticker}'
declare @SecurityID int = (select SecurityID from XFDATA.dbo.SECURITY where Ticker = @Ticker)
declare @DateStart datetime = '{date_start}'            -- yyyy-MM-dd
declare @DateEnd datetime = '{date_end}'                -- yyyy-MM-dd
declare @Expiration datetime = '{date_expiration}'      -- yyyy-MM-dd

SELECT
  sp.Date, CallPut,
  MIN(ClosePrice)                                                                    AS ClosePrice,
  @Expiration                                                                        AS Expiration,
  MIN(XF.dbo.mbbo(op.BestBid,op.BestOffer))                                          AS MBBO,
  xf.dbo.formatStrike(op.Strike)                                                     AS Strike,
  MIN(sp.ClosePrice) - XF.dbo.formatStrike(op.Strike)                                AS StrikeDiff,
  MIN(ImpliedVolatility)							     AS ImpliedVolatility,
  op.Delta                                                                           AS Delta,
  XF.[db_datawriter].InterpolateRate(DATEDIFF(day,sp.Date,@Expiration+1), sp.Date)   AS ZeroRate
INTO diff_table
FROM XFDATA.dbo.SECURITY_PRICE sp
  INNER JOIN XFDATA.dbo.OPTION_PRICE_VIEW op ON sp.SecurityID = op.SecurityID
             AND sp.Date = op.Date AND op.Expiration=@Expiration + 1 -- For saturday expiration

WHERE sp.SecurityID = @SecurityID AND sp.Date BETWEEN @DateStart AND @DateEnd
      AND op.SpecialSettlement=0 --Eliminate Mini Options

GROUP BY sp.Date, op.CallPut, op.Strike, op.Delta

SELECT
  diff_table.*
INTO ATM_High
FROM diff_table
  INNER JOIN (
               SELECT
                 MIN(diff_table.StrikeDiff) AS StrikeDiff,
                 diff_table.Date
               FROM diff_table
               WHERE StrikeDiff>0

               GROUP BY diff_table.Date, diff_table.CallPut
             ) dt ON diff_table.StrikeDiff = dt.StrikeDiff
                     AND diff_table.Date = dt.Date
ORDER BY Date

SELECT
  diff_table.*
INTO ATM_Low
FROM diff_table
  INNER JOIN (
               SELECT
                 MAX(diff_table.StrikeDiff) AS StrikeDiff,
                 diff_table.Date
               FROM diff_table
               WHERE StrikeDiff<0

               GROUP BY diff_table.Date, diff_table.CallPut
             ) dt ON diff_table.StrikeDiff = dt.StrikeDiff
                     AND diff_table.Date = dt.Date
ORDER BY Date

SELECT
  Date,
  SUM(Delta) AS StraddleDelta,
  Strike
INTO Straddle_delta
FROM diff_table
GROUP BY Date,Strike

SELECT
  diff_table.*
INTO Delta_Low
FROM diff_table
  INNER JOIN (
               SELECT
                 s1.Date AS Date,
                 s1.StraddleDelta AS StraddleDelta,
                 Strike
               FROM Straddle_delta s1 INNER JOIN
                 (select min(StraddleDelta) AS StraddleDelta, Date
                  from Straddle_delta
                  WHERE StraddleDelta > 0
                  GROUP BY Date) s2
                   ON s1.StraddleDelta=s2.StraddleDelta AND s1.Date=s2.Date
               WHERE s1.StraddleDelta BETWEEN -1 and 1
             ) dt ON diff_table.Date = dt.Date
                     AND diff_table.Strike = dt.Strike
ORDER BY Date

SELECT
  diff_table.*
INTO Delta_High
FROM diff_table
  INNER JOIN (
               SELECT
                 s1.Date AS Date,
                 s1.StraddleDelta AS StraddleDelta,
                 Strike
               FROM Straddle_delta s1 INNER JOIN
                 (select MAX(StraddleDelta) AS StraddleDelta, Date
                  from Straddle_delta
                  WHERE StraddleDelta < 0
                  GROUP BY Date) s2
                   ON s1.StraddleDelta=s2.StraddleDelta AND s1.Date=s2.Date
               WHERE s1.StraddleDelta BETWEEN -1 and 1
             ) dt ON diff_table.Date = dt.Date
                     AND diff_table.Strike = dt.Strike
ORDER BY Date

-- Combine data
SELECT *,'S' as ATMethod
from ATM_Low
union
SELECT *,'S' as ATMethod
FROM ATM_High
union
SELECT *, 'D' as ATMethod
FROM Delta_Low
UNION
SELECT *, 'D' as ATMethod
FROM Delta_High

drop TABLE diff_table, ATM_High, ATM_Low, Delta_High, Delta_Low, Straddle_delta

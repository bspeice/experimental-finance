-- Parameters are set externally
declare @SecurityID int = {sec_id}
declare @DateStart datetime = '{date_start}'            -- yyyy-MM-dd
declare @DateEnd datetime = '{date_end}'                -- yyyy-MM-dd
declare @Expiration datetime = '{date_expiration}'      -- yyyy-MM-dd
declare @OptType char = '{opt_type}'

/*
	The query selects two ATM option series for each of the different methods we have considered.
	First method is selecting the lower and higher strikes in which the current stock price is contained
	and will be used for options with lower time to maturity. Second method selects the strikes with
	smallest straddle delta value in which straddle delta=0 is contained.
*/

SELECT
  sp.Date, CallPut,
  ClosePrice                                                                         AS ClosePrice,
  xf.dbo.formatStrike(op.Strike)                                                     AS Strike,
  @Expiration                                                                        AS Expiration,
  XF.dbo.mbbo(op.BestBid,op.BestOffer)                                               AS MBBO,
  op.BestOffer-op.BestBid                                                            AS Spread,
  ImpliedVolatility							             AS ImpliedVolatility,
  OpenInterest, op.Volume, op.Delta,
  XF.[db_datawriter].InterpolateRate(DATEDIFF(day,sp.Date,@Expiration), sp.Date)     AS ZeroRate
INTO #diff_table
FROM XFDATA.dbo.SECURITY_PRICE sp
  INNER JOIN XFDATA.dbo.OPTION_PRICE_VIEW op ON sp.SecurityID = op.SecurityID
                                                AND sp.Date = op.Date AND op.Expiration=@Expiration -- For saturday expiration

WHERE sp.SecurityID = @SecurityID AND sp.Date BETWEEN @DateStart AND @DateEnd
      AND op.SpecialSettlement=0 --Eliminate Mini Options
      AND op.CallPut=@OptType

SELECT dt.* FROM XF.db_datawriter.EventStrikes es INNER JOIN #diff_table dt
  on es.Strike=dt.Strike
  order by dt.Date

drop TABLE #diff_table, XF.db_datawriter.EventStrikes


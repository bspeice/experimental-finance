DROP TABLE XF.db_datawriter.bcs2149_earningsTrades

CREATE TABLE XF.db_datawriter.bcs2149_earningsTrades (
  SecurityId        INT,
  EarningsDate      SMALLDATETIME,
  PriorCheck        SMALLDATETIME,
  CloseDate         SMALLDATETIME,
--   EarningsDate      DATETIME,
--   PriorCheck        DATETIME,
--   CloseDate         DATETIME,
  Expiration        DATE,
  OpenInterest      INT,
  OpenInterestPrior INT,
  CallPut           CHAR,
  Strike            DECIMAL(6, 2),
  TradeOpenPrice    DECIMAL(6, 2),
  TradeClosePrice   DECIMAL(6, 2),
  Surprise          DECIMAL(4, 2),
  EPS               DECIMAL(4, 2),
--   Strike            FLOAT,
--   TradeOpenPrice    FLOAT,
--   TradeClosePrice   FLOAT,
--   Surprise          FLOAT,
--   EPS               FLOAT,
  Ticker            VARCHAR(MAX),
  BusDaysPrior      INT,
  BusDaysAfter      INT,
  StrikeDiff        FLOAT,
  ExpDiff           INT

    CONSTRAINT pk_earningsTrades PRIMARY KEY (
      EarningsDate,
      SecurityId,
      Strike,
      Expiration,
      CallPut,
      BusDaysPrior,
      BusDaysAfter
    )
)
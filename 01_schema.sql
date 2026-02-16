-- AML TRANSACTION MONITORING (SQL SERVER / T-SQL)



CREATE TABLE dbo.customers (
  customer_id      BIGINT IDENTITY(1,1) PRIMARY KEY,
  full_name        NVARCHAR(120) NOT NULL,
  dob              DATE NOT NULL,
  nationality      NVARCHAR(80) NOT NULL,
  resident_country NVARCHAR(80) NOT NULL,
  risk_rating      VARCHAR(10) NOT NULL
    CONSTRAINT CK_customers_risk CHECK (risk_rating IN ('LOW','MEDIUM','HIGH')),
  onboarding_date  DATE NOT NULL
);
GO

CREATE TABLE dbo.accounts (
  account_id    BIGINT IDENTITY(1,1) PRIMARY KEY,
  customer_id   BIGINT NOT NULL
    CONSTRAINT FK_accounts_customers FOREIGN KEY REFERENCES dbo.customers(customer_id),
  account_type  VARCHAR(10) NOT NULL
    CONSTRAINT CK_accounts_type CHECK (account_type IN ('CURRENT','SAVINGS','BUSINESS')),
  open_date     DATE NOT NULL,
  status        VARCHAR(12) NOT NULL DEFAULT 'ACTIVE'
    CONSTRAINT CK_accounts_status CHECK (status IN ('ACTIVE','FROZEN','CLOSED'))
);
GO

CREATE TABLE dbo.transactions (
  tx_id              BIGINT IDENTITY(1,1) PRIMARY KEY,
  account_id         BIGINT NOT NULL
    CONSTRAINT FK_tx_accounts FOREIGN KEY REFERENCES dbo.accounts(account_id),
  tx_time            DATETIME2(0) NOT NULL,
  direction          VARCHAR(3) NOT NULL
    CONSTRAINT CK_tx_direction CHECK (direction IN ('IN','OUT')),
  amount             DECIMAL(14,2) NOT NULL
    CONSTRAINT CK_tx_amount CHECK (amount > 0),
  currency           CHAR(3) NOT NULL DEFAULT 'GBP',
  channel            VARCHAR(10) NOT NULL
    CONSTRAINT CK_tx_channel CHECK (channel IN ('CARD','TRANSFER','CASH','ONLINE','ATM')),
  merchant_category  NVARCHAR(80) NULL,
  counterparty_country CHAR(2) NOT NULL, -- use ISO country codes e.g. UK, CN, AE
  description        NVARCHAR(200) NULL
);
GO

CREATE TABLE dbo.alerts (
  alert_id     BIGINT IDENTITY(1,1) PRIMARY KEY,
  customer_id  BIGINT NOT NULL
    CONSTRAINT FK_alerts_customers FOREIGN KEY REFERENCES dbo.customers(customer_id),
  alert_type   NVARCHAR(60) NOT NULL,
  created_at   DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
  severity     VARCHAR(10) NOT NULL
    CONSTRAINT CK_alerts_sev CHECK (severity IN ('LOW','MEDIUM','HIGH')),
  status       VARCHAR(30) NOT NULL DEFAULT 'OPEN'
    CONSTRAINT CK_alerts_status CHECK (status IN ('OPEN','INVESTIGATING','CLOSED_FALSE_POSITIVE','CLOSED_CONFIRMED')),
  notes        NVARCHAR(400) NULL
);
GO

CREATE TABLE dbo.sar_cases (
  case_id      BIGINT IDENTITY(1,1) PRIMARY KEY,
  customer_id  BIGINT NOT NULL
    CONSTRAINT FK_cases_customers FOREIGN KEY REFERENCES dbo.customers(customer_id),
  created_at   DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
  outcome      VARCHAR(10) NOT NULL
    CONSTRAINT CK_cases_outcome CHECK (outcome IN ('FILED','NOT_FILED','PENDING')),
  summary      NVARCHAR(400) NULL
);
GO
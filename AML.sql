-- AML TRANSACTION MONITORING (SQL SERVER / T-SQL)
IF OBJECT_ID('dbo.sar_cases','U') IS NOT NULL DROP TABLE dbo.sar_cases;
IF OBJECT_ID('dbo.alerts','U') IS NOT NULL DROP TABLE dbo.alerts;
IF OBJECT_ID('dbo.transactions','U') IS NOT NULL DROP TABLE dbo.transactions;
IF OBJECT_ID('dbo.accounts','U') IS NOT NULL DROP TABLE dbo.accounts;
IF OBJECT_ID('dbo.customers','U') IS NOT NULL DROP TABLE dbo.customers;
GO

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

INSERT INTO dbo.customers (full_name, dob, nationality, resident_country, risk_rating, onboarding_date) VALUES
(N'Aisha Bello', '1996-04-12', N'Nigerian', N'UK', 'MEDIUM', '2024-01-10'),
(N'John Smith',  '1988-09-22', N'British',  N'UK', 'LOW',    '2023-11-05'),
(N'Mei Chen',    '1992-06-30', N'Chinese',  N'UK', 'MEDIUM', '2024-03-18'),
(N'Omar Hassan', '1985-02-14', N'Egyptian', N'UK', 'HIGH',   '2023-07-01'),
(N'Carlos Lima', '1990-12-02', N'Brazilian',N'UK', 'LOW',    '2024-02-05'),
(N'Fatima Ali',  '1998-08-08', N'Pakistani',N'UK', 'HIGH',   '2024-04-20');

INSERT INTO dbo.accounts (customer_id, account_type, open_date, status) VALUES
(1, 'CURRENT',  '2024-01-10', 'ACTIVE'),
(1, 'SAVINGS',  '2024-02-01', 'ACTIVE'),
(2, 'CURRENT',  '2023-11-05', 'ACTIVE'),
(3, 'CURRENT',  '2024-03-18', 'ACTIVE'),
(4, 'BUSINESS', '2023-07-01', 'ACTIVE'),
(5, 'CURRENT',  '2024-02-05', 'ACTIVE'),
(6, 'CURRENT',  '2024-04-20', 'ACTIVE');

INSERT INTO dbo.transactions
(account_id, tx_time, direction, amount, currency, channel, merchant_category, counterparty_country, description)
VALUES
-- Aisha: near-10k structuring transfers
(1, '2025-01-12 10:05:00', 'OUT', 9990.00, 'GBP', 'TRANSFER', NULL, 'UK', N'Transfer out'),
(1, '2025-01-12 14:20:00', 'OUT', 9985.00, 'GBP', 'TRANSFER', NULL, 'UK', N'Transfer out'),
(1, '2025-01-12 18:40:00', 'OUT', 9975.00, 'GBP', 'TRANSFER', NULL, 'UK', N'Transfer out'),
(1, '2025-01-13 11:10:00', 'OUT', 9995.00, 'GBP', 'TRANSFER', NULL, 'UK', N'Transfer out'),
(1, '2025-01-13 16:25:00', 'OUT', 9990.00, 'GBP', 'TRANSFER', NULL, 'UK', N'Transfer out'),

-- John: normal spend
(3, '2025-01-10 12:01:00', 'OUT', 12.50, 'GBP', 'CARD', N'GROCERIES',  'UK', N'Groceries'),
(3, '2025-01-12 19:11:00', 'OUT', 45.90, 'GBP', 'CARD', N'RESTAURANT', 'UK', N'Dinner'),
(3, '2025-01-18 09:32:00', 'OUT', 120.00,'GBP', 'CARD', N'ELECTRONICS','UK', N'Headphones'),

-- Mei: round amounts + corridor
(4, '2025-01-20 08:15:00', 'IN',  5000.00, 'GBP', 'TRANSFER', NULL, 'CN', N'Incoming transfer'),
(4, '2025-01-21 10:00:00', 'OUT', 5000.00, 'GBP', 'TRANSFER', NULL, 'AE', N'Outgoing transfer'),
(4, '2025-01-21 10:07:00', 'OUT', 5000.00, 'GBP', 'TRANSFER', NULL, 'AE', N'Outgoing transfer'),

-- Omar: high velocity cash outs
(5, '2025-02-01 09:00:00', 'IN',  20000.00, 'GBP', 'TRANSFER', NULL, 'UK', N'Client payment'),
(5, '2025-02-01 09:12:00', 'OUT', 8000.00,  'GBP', 'CASH', NULL, 'UK', N'Cash withdrawal'),
(5, '2025-02-01 09:20:00', 'OUT', 7000.00,  'GBP', 'CASH', NULL, 'UK', N'Cash withdrawal'),
(5, '2025-02-01 09:28:00', 'OUT', 6000.00,  'GBP', 'CASH', NULL, 'UK', N'Cash withdrawal'),

-- Carlos: normal
(6, '2025-01-05 15:10:00', 'IN',  2500.00, 'GBP', 'TRANSFER', NULL, 'UK', N'Salary'),
(6, '2025-01-06 13:00:00', 'OUT', 300.00,  'GBP', 'CARD', N'TRAVEL',    'UK', N'Train'),
(6, '2025-01-07 18:50:00', 'OUT', 80.00,   'GBP', 'CARD', N'RESTAURANT','UK', N'Food'),

-- Fatima: many small quick online payments to risky corridor
(7, '2025-02-10 10:00:00', 'IN',  1500.00, 'GBP', 'TRANSFER', NULL, 'UK', N'Incoming'),
(7, '2025-02-10 10:02:00', 'OUT', 250.00,  'GBP', 'ONLINE', N'CRYPTO_EXCHANGE', 'TR', N'Online payment'),
(7, '2025-02-10 10:04:00', 'OUT', 250.00,  'GBP', 'ONLINE', N'CRYPTO_EXCHANGE', 'TR', N'Online payment'),
(7, '2025-02-10 10:06:00', 'OUT', 250.00,  'GBP', 'ONLINE', N'CRYPTO_EXCHANGE', 'TR', N'Online payment'),
(7, '2025-02-10 10:08:00', 'OUT', 250.00,  'GBP', 'ONLINE', N'CRYPTO_EXCHANGE', 'TR', N'Online payment');


CREATE INDEX idx_accounts_customer ON dbo.accounts(customer_id);
CREATE INDEX idx_tx_account_time  ON dbo.transactions(account_id, tx_time);
CREATE INDEX idx_tx_country_time  ON dbo.transactions(counterparty_country, tx_time);
CREATE INDEX idx_alerts_customer_time ON dbo.alerts(customer_id, created_at);
GO


CREATE OR ALTER VIEW dbo.v_customer_tx_summary AS
SELECT
  c.customer_id,
  c.full_name,
  c.risk_rating,
  COUNT(t.tx_id) AS tx_count,
  SUM(CASE WHEN t.direction='IN'  THEN t.amount ELSE 0 END) AS total_in,
  SUM(CASE WHEN t.direction='OUT' THEN t.amount ELSE 0 END) AS total_out,
  MIN(t.tx_time) AS first_tx_time,
  MAX(t.tx_time) AS last_tx_time
FROM dbo.customers c
JOIN dbo.accounts a ON a.customer_id = c.customer_id
LEFT JOIN dbo.transactions t ON t.account_id = a.account_id
GROUP BY c.customer_id, c.full_name, c.risk_rating;
GO

SELECT
  a.customer_id,
  COUNT(*) AS near_threshold_count,
  SUM(t.amount) AS near_threshold_total,
  MIN(t.tx_time) AS first_time,
  MAX(t.tx_time) AS last_time
FROM dbo.accounts a
JOIN dbo.transactions t ON t.account_id = a.account_id
WHERE t.direction='OUT'
  AND t.channel='TRANSFER'
  AND t.amount >= 9000 AND t.amount < 10000
GROUP BY a.customer_id
HAVING COUNT(*) >= 3
ORDER BY near_threshold_total DESC;


WITH ordered AS (
  SELECT
    t.*,
    LAG(tx_time) OVER (PARTITION BY account_id ORDER BY tx_time) AS prev_time
  FROM dbo.transactions t
)
SELECT
  account_id, tx_id, tx_time, prev_time,
  DATEDIFF(MINUTE, prev_time, tx_time) AS minutes_since_prev
FROM ordered
WHERE prev_time IS NOT NULL
  AND DATEDIFF(MINUTE, prev_time, tx_time) BETWEEN 0 AND 10
ORDER BY account_id, tx_time;

SELECT tx_id, account_id, tx_time, direction, amount, channel, counterparty_country
FROM dbo.transactions
WHERE amount % 1000 = 0
ORDER BY amount DESC, tx_time;

WITH tx AS (
  SELECT
    t.*,
    LAG(direction) OVER (PARTITION BY account_id ORDER BY tx_time) AS prev_dir,
    LAG(amount)    OVER (PARTITION BY account_id ORDER BY tx_time) AS prev_amt,
    LAG(tx_time)   OVER (PARTITION BY account_id ORDER BY tx_time) AS prev_time
  FROM dbo.transactions t
)
SELECT account_id, tx_id, tx_time, direction, amount, prev_dir, prev_amt, prev_time
FROM tx
WHERE prev_dir='IN'
  AND direction='OUT'
  AND DATEDIFF(MINUTE, prev_time, tx_time) BETWEEN 0 AND 60
ORDER BY account_id, tx_time;


WITH features AS (
  SELECT
    c.customer_id,
    c.full_name,
    c.risk_rating,
    SUM(CASE WHEN t.direction='OUT' AND t.amount >= 9000 AND t.amount < 10000 THEN 1 ELSE 0 END) AS near_10k_count,
    SUM(CASE WHEN t.counterparty_country <> 'UK' THEN 1 ELSE 0 END) AS non_uk_count,
    SUM(CASE WHEN t.channel='CASH' AND t.direction='OUT' THEN t.amount ELSE 0 END) AS cash_out_amt,
    COUNT(t.tx_id) AS tx_count
  FROM dbo.customers c
  JOIN dbo.accounts a ON a.customer_id=c.customer_id
  JOIN dbo.transactions t ON t.account_id=a.account_id
  GROUP BY c.customer_id, c.full_name, c.risk_rating
),
scored AS (
  SELECT *,
    (CASE risk_rating WHEN 'HIGH' THEN 30 WHEN 'MEDIUM' THEN 15 ELSE 5 END)
    + (near_10k_count * 10)
    + (non_uk_count * 2)
    + (CASE WHEN cash_out_amt >= 10000 THEN 10 ELSE 0 END) AS risk_score
  FROM features
)
SELECT *
FROM scored
ORDER BY risk_score DESC, tx_count DESC;

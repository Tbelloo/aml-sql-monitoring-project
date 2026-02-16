--Views

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

--Queries

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

--Sample data

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

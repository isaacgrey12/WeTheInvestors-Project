-- Optional tiny seed for UI dev
INSERT INTO politicians (full_name, chamber, party, state, district) VALUES
('Jane Doe', 'House', 'D', 'CA', '12')
ON CONFLICT DO NOTHING;


INSERT INTO tickers (symbol, company_name) VALUES
('AAPL', 'Apple Inc.'),
('MSFT', 'Microsoft Corp.')
ON CONFLICT DO NOTHING;


INSERT INTO trades (politician_id, ticker_id, raw_ticker, transaction_type, asset_type, date_traded, date_filed, amount_min, amount_max, source, source_txn_id, notes)
SELECT p.id, t.id, 'AAPL', 'Buy', 'Stock', '2025-10-01', '2025-10-05', 1000, 15000, 'Seed', 'seed-1', '{"demo":true}'::jsonb
FROM politicians p, tickers t
WHERE p.full_name='Jane Doe' AND t.symbol='AAPL'
ON CONFLICT DO NOTHING;
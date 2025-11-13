-- Core reference tables
CREATE TABLE IF NOT EXISTS politicians (
id SERIAL PRIMARY KEY,
bioguide_id TEXT UNIQUE,
full_name TEXT NOT NULL,
chamber TEXT NOT NULL CHECK (chamber IN ('House','Senate')),
party TEXT CHECK (party IN ('D','R','I')),
state TEXT,
district TEXT,
created_at TIMESTAMPTZ DEFAULT now()
);


CREATE TABLE IF NOT EXISTS tickers (
id SERIAL PRIMARY KEY,
symbol TEXT NOT NULL UNIQUE,
company_name TEXT
);


CREATE TABLE IF NOT EXISTS trades (
id BIGSERIAL PRIMARY KEY,
politician_id INTEGER NOT NULL REFERENCES politicians(id),
ticker_id INTEGER REFERENCES tickers(id),
raw_ticker TEXT,
transaction_type TEXT NOT NULL CHECK (transaction_type IN ('Buy','Sell','Other')),
asset_type TEXT,
date_traded DATE,
date_filed DATE,
amount_min NUMERIC,
amount_max NUMERIC,
source TEXT,
source_txn_id TEXT,
notes JSONB,
created_at TIMESTAMPTZ DEFAULT now(),
UNIQUE (source, source_txn_id)
);


CREATE TABLE IF NOT EXISTS anon_devices (
id UUID PRIMARY KEY,
created_at TIMESTAMPTZ DEFAULT now()
);


CREATE TABLE IF NOT EXISTS follows (
device_id UUID REFERENCES anon_devices(id) ON DELETE CASCADE,
politician_id INTEGER REFERENCES politicians(id) ON DELETE CASCADE,
PRIMARY KEY (device_id, politician_id)
);


CREATE TABLE IF NOT EXISTS ticker_trade_stats_daily (
dt DATE NOT NULL,
ticker_id INTEGER NOT NULL REFERENCES tickers(id),
trade_count INTEGER NOT NULL,
buy_count INTEGER NOT NULL,
sell_count INTEGER NOT NULL,
PRIMARY KEY (dt, ticker_id)
);


-- Helpful indexes
CREATE INDEX IF NOT EXISTS trades_date_filed_idx ON trades (date_filed DESC);
CREATE INDEX IF NOT EXISTS trades_date_traded_idx ON trades (date_traded DESC);
CREATE INDEX IF NOT EXISTS trades_politician_date_idx ON trades (politician_id, date_traded DESC);
CREATE INDEX IF NOT EXISTS trades_ticker_date_idx ON trades (ticker_id, date_traded DESC);
CREATE INDEX IF NOT EXISTS trades_txn_type_idx ON trades (transaction_type);
CREATE INDEX IF NOT EXISTS politicians_name_idx ON politicians (full_name);
CREATE INDEX IF NOT EXISTS tickers_symbol_idx ON tickers (symbol);
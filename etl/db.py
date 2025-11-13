from __future__ import annotations
import os
import psycopg2
from psycopg2.extras import execute_values


class DB:
    def __init__(self, dsn: str):
        self.dsn = dsn

    def connect(self):
        return psycopg2.connect(self.dsn)


    def upsert_politicians(self, cur, rows):
        sql = """
        INSERT INTO politicians (bioguide_id, full_name, chamber, party, state, district)
        VALUES %s
        ON CONFLICT (bioguide_id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        chamber = EXCLUDED.chamber,
        party = EXCLUDED.party,
        state = EXCLUDED.state,
        district = EXCLUDED.district
        RETURNING id, bioguide_id;
        """
        return self._exec_values(cur, sql, rows)


    def upsert_tickers(self, cur, rows):
        sql = """
        INSERT INTO tickers (symbol, company_name)
        VALUES %s
        ON CONFLICT (symbol) DO UPDATE SET company_name = COALESCE(EXCLUDED.company_name, tickers.company_name)
        RETURNING id, symbol;
        """
        return self._exec_values(cur, sql, rows)


    def upsert_trades(self, cur, rows):
        sql = """
        INSERT INTO trades (
            politician_id, ticker_id, raw_ticker, transaction_type, asset_type,
            date_traded, date_filed, amount_min, amount_max, source, source_txn_id, notes
        ) VALUES %s
        ON CONFLICT (source, source_txn_id) DO UPDATE SET
            politician_id = EXCLUDED.politician_id,
            ticker_id = EXCLUDED.ticker_id,
            raw_ticker = EXCLUDED.raw_ticker,
            transaction_type = EXCLUDED.transaction_type,
            asset_type = EXCLUDED.asset_type,
            date_traded = EXCLUDED.date_traded,
            date_filed = EXCLUDED.date_filed,
            amount_min = EXCLUDED.amount_min,
            amount_max = EXCLUDED.amount_max,
            notes = EXCLUDED.notes;
        """
        execute_values(cur, sql, rows, page_size=500)

    @staticmethod
    def _exec_values(cur, sql, rows):
        if not rows:
            return []
        execute_values(cur, sql, rows, page_size=500)
        return cur.fetchall()

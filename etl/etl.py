from __future__ import annotations
import os
import json
import math
import argparse
from datetime import datetime, date, timedelta, timezone
from collections import defaultdict
from dotenv import load_dotenv


from db import DB
from quiver_client import QuiverClient
from normalize import normalize_record


load_dotenv()


DEF_BATCH = int(os.getenv("BATCH_SIZE", 500))
DATABASE_URL = os.getenv("DATABASE_URL")
SOURCE = os.getenv("SOURCE", "Quiver")


def json_serialize(obj):
    """Convert object to JSON-serializable format, handling pandas Timestamps, NaN, and other types."""
    # Handle pandas Timestamp and other date-like objects
    if hasattr(obj, 'isoformat') and callable(getattr(obj, 'isoformat', None)):
        try:
            return obj.isoformat()
        except (AttributeError, TypeError):
            pass
    # Handle datetime/date objects
    if isinstance(obj, (datetime, date)):
        return obj.isoformat()
    # Check for pandas NA (pd.NA) - check this early
    try:
        import pandas as pd
        if obj is pd.NA or (hasattr(pd, 'isna') and pd.isna(obj)):
            return None
    except (ImportError, AttributeError):
        pass
    # Check for numpy/pandas NaN (might be a float-like object) - check before basic float
    try:
        import numpy as np
        if isinstance(obj, (np.floating, np.integer)):
            if isinstance(obj, np.floating) and (np.isnan(obj) or np.isinf(obj)):
                return None
            return float(obj) if isinstance(obj, np.floating) else int(obj)
    except ImportError:
        pass
    # Handle NaN, Infinity, -Infinity (not valid in JSON) - Python float
    if isinstance(obj, float):
        if math.isnan(obj):
            return None  # Convert NaN to null
        if math.isinf(obj):
            return None  # Convert Infinity to null
        return obj
    # Handle dicts recursively
    if isinstance(obj, dict):
        return {k: json_serialize(v) for k, v in obj.items()}
    # Handle lists/tuples recursively
    if isinstance(obj, (list, tuple)):
        return [json_serialize(item) for item in obj]
    # Already JSON-serializable types
    if isinstance(obj, (int, str, bool, type(None))):
        return obj
    # Fallback: convert to string
    return str(obj)




def parse_args():
    p = argparse.ArgumentParser(description="Ingest congressional trading data from Quiver into Postgres")
    p.add_argument("--since", default="7d", help="How far back to fetch, e.g. 7d, 30d, 2025-10-01")
    p.add_argument("--limit", type=int, default=5000, help="Max records to process in this run")
    return p.parse_args()




def compute_since(s: str) -> datetime:
    try:
        if s.endswith("d"):
            days = int(s[:-1])
            return datetime.now(timezone.utc) - timedelta(days=days)
        # ISO date
        return datetime.fromisoformat(s).replace(tzinfo=timezone.utc)
    except Exception:
        return datetime.now(timezone.utc) - timedelta(days=7)




def main():
    assert DATABASE_URL, "DATABASE_URL is not set"
    args = parse_args()
    since = compute_since(args.since)


    client = QuiverClient()
    raw = client.fetch_congress_trades(since)
    if not raw:
        print("No records returned from Quiver.")
        return


    # Normalize
    norm = [normalize_record(r) for r in raw][: args.limit]


    # Prepare dimension upserts
    pol_rows = []
    tic_rows = []
    seen_bioguide_ids = set()  # Track unique bioguide IDs to avoid duplicates
    seen_symbols = set()  # Track unique symbols to avoid duplicates
    for n in norm:
        if n.bioguide_id and n.bioguide_id not in seen_bioguide_ids:
            pol_rows.append((n.bioguide_id, n.member_name, n.chamber, n.party, n.state, n.district))
            seen_bioguide_ids.add(n.bioguide_id)
        if n.symbol and n.symbol not in seen_symbols:
            tic_rows.append((n.symbol, None))
            seen_symbols.add(n.symbol)


    db = DB(DATABASE_URL)
    with db.connect() as conn:
        with conn.cursor() as cur:
            pol_map = {}
            if pol_rows:
                ret = db.upsert_politicians(cur, pol_rows)
                pol_map = {bioguide: pid for (pid, bioguide) in ret if bioguide}


            tic_map = {}
            if tic_rows:
                ret2 = db.upsert_tickers(cur, tic_rows)
                tic_map = {sym: tid for (tid, sym) in ret2}


            # Prepare trade rows
            trade_rows = []
            seen_trades = set()  # Track (source, source_txn_id) pairs to avoid duplicates
            for n in norm:
                # Skip if we've already seen this (source, source_txn_id) combination
                trade_key = (SOURCE, n.source_txn_id)
                if trade_key in seen_trades:
                    continue
                seen_trades.add(trade_key)
                pol_id = pol_map.get(n.bioguide_id)
                # fallback: try to select by name if no bioguide provided
                if not pol_id and n.member_name:
                    cur.execute("SELECT id FROM politicians WHERE full_name=%s LIMIT 1", (n.member_name,))
                    row = cur.fetchone()
                    if row:
                        pol_id = row[0]
                    else:
                        cur.execute(
                            "INSERT INTO politicians (bioguide_id, full_name, chamber, party, state, district) VALUES (%s,%s,%s,%s,%s,%s) RETURNING id",
                            (n.bioguide_id, n.member_name, n.chamber, n.party, n.state, n.district),
                        )
                        pol_id = cur.fetchone()[0]


                ticker_id = tic_map.get((n.symbol or "")) if n.symbol else None
                if not ticker_id and n.symbol:
                    cur.execute("INSERT INTO tickers (symbol) VALUES (%s) ON CONFLICT (symbol) DO UPDATE SET symbol=EXCLUDED.symbol RETURNING id", (n.symbol,))
                    ticker_id = cur.fetchone()[0]


                trade_rows.append(
                    (
                        pol_id,
                        ticker_id,
                        n.raw_ticker,
                        n.txn,
                        n.asset_type,
                        n.date_traded,
                        n.date_filed,
                        n.amount_min,
                        n.amount_max,
                        SOURCE,
                        n.source_txn_id,
                        json.dumps(json_serialize(n.raw)) if n.raw else None,
                    )
                )


            db.upsert_trades(cur, trade_rows)
            conn.commit()


    print(f"✅ Ingested/updated {len(norm)} records since {since.isoformat()}")


if __name__ == "__main__":
    main()

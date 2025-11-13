from __future__ import annotations
import os
from datetime import datetime, timedelta, timezone
from typing import Iterable, Optional
from dataclasses import dataclass


from dotenv import load_dotenv


# Prefer official Python client; falls back to raw HTTP if missing
try:
    import quiverquant # type: ignore
except Exception: # pragma: no cover
    quiverquant = None

import requests

load_dotenv()

API_KEY = os.getenv("QUVER_API_KEY")
BASE = "https://api.quiverquant.com"
HEADERS = {"Authorization": f"Token {API_KEY}"}


@dataclass
class TradeRecord:
    source_id: str
    ticker: str | None
    raw: dict


class QuiverClient:
    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or API_KEY
        if not self.api_key:
            raise RuntimeError("QUVER_API_KEY is not set")


    def fetch_congress_trades(self, since: datetime) -> list[dict]:
        """
        Returns recent congress trading disclosures since a timestamp.
        Tries quiverquant python client first; falls back to REST.
        """
        if quiverquant:
            q = quiverquant.quiver(self.api_key)
            # quiver.congress_trading() returns recent trades; filtering by date in code
            df = q.congress_trading()
            # convert pandas DataFrame rows to dict
            records = df.to_dict(orient="records")
            return [r for r in records if _parse_date(r.get("TransactionDate") or r.get("Date")) >= since.date()]
        else:
            # REST fallback. Endpoint path may vary by plan; this uses common beta path.
            # If your plan requires a different path, adjust BASE_PATH below.
            BASE_PATH = "/beta/congresstrading" # NOTE: adjust if your plan differs
            url = f"{BASE}{BASE_PATH}"
            resp = requests.get(url, headers=HEADERS, timeout=30)
            resp.raise_for_status()
            data = resp.json()
            return [r for r in data if _parse_date(r.get("TransactionDate") or r.get("Date")) >= since.date()]


def _parse_date(s: str | None):
    from datetime import datetime, date
    if not s:
        return datetime.min.date()
    
    # Handle datetime objects directly
    if isinstance(s, datetime):
        return s.date()
    if isinstance(s, date):
        return s
    
    # Handle pandas Timestamp or other date-like objects with .date() method
    if hasattr(s, 'date'):
        try:
            date_method = getattr(s, 'date')
            if callable(date_method):
                return date_method()
        except (AttributeError, TypeError):
            pass
    
    # Convert to string if it's not already
    if not isinstance(s, str):
        s = str(s)
    
    # Try parsing as string
    for fmt in ("%Y-%m-%d", "%m/%d/%Y", "%Y/%m/%d"):
        try:
            return datetime.strptime(s, fmt).date()
        except (ValueError, TypeError):
            continue
    return datetime.min.date()

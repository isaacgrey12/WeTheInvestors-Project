from __future__ import annotations
import os
from typing import Optional
from fastapi import FastAPI, Header, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv


from db import init_pool, get_conn
from models import FeedResponse, TradeItem, Member, Ticker
from pagination import encode_cursor, decode_cursor
from queries import feed_query, member_by_id, ticker_by_symbol, trending_query


load_dotenv()


app = FastAPI(title="Congressional Stock Tracker API", version="0.1")


ALLOWED = os.getenv("ALLOWED_ORIGINS", "*").split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL is not set")
init_pool(DATABASE_URL)




@app.get("/health")
def health():
    return {"ok": True}




@app.get("/v1/feed", response_model=FeedResponse)
def get_feed(
    limit: int = Query(50, ge=1, le=200),
    cursor: Optional[str] = None,
    chamber: Optional[str] = Query(None, pattern="^(House|Senate)$"),
    party: Optional[str] = Query(None, pattern="^(D|R|I)$"),
    txn: Optional[str] = Query(None, pattern="^(Buy|Sell|Other)$"),
    start: Optional[str] = None,
    end: Optional[str] = None,
    ticker: Optional[str] = None,
):
    params = {
        "limit": limit,
        "cursor": cursor,
        "chamber": chamber,
        "party": party,
        "txn": txn,
        "start": start,
        "end": end,
        "ticker": ticker,
    }
    with get_conn() as conn:
        items, next_cursor = feed_query(conn, params)
    return FeedResponse(items=items, nextCursor=next_cursor)


@app.get("/v1/members/{member_id}", response_model=Member)
def get_member(member_id: int):
    with get_conn() as conn:
        member = member_by_id(conn, member_id)
    if not member:
        raise HTTPException(status_code=404, detail="Member not found")
    return member


@app.get("/v1/tickers/{symbol}", response_model=Ticker)
def get_ticker(symbol: str):
    with get_conn() as conn:
        ticker = ticker_by_symbol(conn, symbol.upper())
    if not ticker:
        raise HTTPException(status_code=404, detail="Ticker not found")
    return ticker


@app.get("/v1/tickers/{symbol}/trades", response_model=FeedResponse)
def get_ticker_trades(
    symbol: str,
    limit: int = Query(50, ge=1, le=200),
    cursor: Optional[str] = None,
    chamber: Optional[str] = Query(None, pattern="^(House|Senate)$"),
    party: Optional[str] = Query(None, pattern="^(D|R|I)$"),
    txn: Optional[str] = Query(None, pattern="^(Buy|Sell|Other)$"),
    start: Optional[str] = None,
    end: Optional[str] = None,
):
    # First verify the ticker exists
    with get_conn() as conn:
        ticker = ticker_by_symbol(conn, symbol.upper())
    if not ticker:
        raise HTTPException(status_code=404, detail="Ticker not found")
    
    # Get trades for this ticker
    params = {
        "limit": limit,
        "cursor": cursor,
        "chamber": chamber,
        "party": party,
        "txn": txn,
        "start": start,
        "end": end,
        "ticker": symbol.upper(),  # Force uppercase
    }
    with get_conn() as conn:
        items, next_cursor = feed_query(conn, params)
    return FeedResponse(items=items, nextCursor=next_cursor)


@app.get("/v1/trending")
def get_trending(
    limit: int = Query(10, ge=1, le=100),
    window_days: int = Query(7, ge=1, le=365),
):
    with get_conn() as conn:
        rows = trending_query(conn, limit, window_days)
    return [{"symbol": r[0], "tradeCount": int(r[1]), "buy": int(r[2]), "sell": int(r[3])} for r in rows]

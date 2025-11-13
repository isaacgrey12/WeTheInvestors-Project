from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple


BASE_SELECT = (
    """
SELECT t.id,
k.symbol,
k.company_name,
t.transaction_type,
p.id as member_id,
p.full_name,
p.chamber,
p.party,
p.state,
p.district,
to_char(t.date_traded, 'YYYY-MM-DD') as date_traded,
to_char(t.date_filed, 'YYYY-MM-DD') as date_filed,
t.amount_min, t.amount_max,
t.asset_type
FROM trades t
JOIN politicians p ON p.id = t.politician_id
LEFT JOIN tickers k ON k.id = t.ticker_id
"""
)




def build_filters(params: Dict[str, Any]) -> Tuple[str, List[Any]]:
    where = ["1=1"]
    vals: List[Any] = []

    if params.get("chamber"):
        where.append("p.chamber = %s")
        vals.append(params["chamber"])
    if params.get("party"):
        where.append("p.party = %s")
        vals.append(params["party"])
    if params.get("txn"):
        where.append("t.transaction_type = %s")
        vals.append(params["txn"])
    if params.get("ticker"):
        where.append("(k.symbol = %s OR t.raw_ticker = %s)")
        vals.extend([params["ticker"].upper(), params["ticker"].upper()])
    if params.get("member_id"):
        where.append("p.id = %s")
        vals.append(int(params["member_id"]))
    if params.get("start"):
        where.append("t.date_filed >= %s")
        vals.append(params["start"])
    if params.get("end"):
        where.append("t.date_filed <= %s")
        vals.append(params["end"])

    sql = " AND ".join(where)
    return sql, vals


def feed_query(conn, params: Dict[str, Any]) -> Tuple[List, Optional[str]]:
    from pagination import encode_cursor, decode_cursor
    from models import TradeItem, Member

    limit = params.get("limit", 50)
    cursor = params.get("cursor")

    where_sql, where_vals = build_filters(params)
    date_filed, id_after = decode_cursor(cursor)

    if date_filed and id_after:
        where_sql += " AND (t.date_filed < %s OR (t.date_filed = %s AND t.id < %s))"
        where_vals.extend([date_filed, date_filed, id_after])

    sql = f"{BASE_SELECT} WHERE {where_sql} ORDER BY t.date_filed DESC, t.id DESC LIMIT %s"
    where_vals.append(limit + 1)

    with conn.cursor() as cur:
        cur.execute(sql, where_vals)
        rows = cur.fetchall()

    items = []
    next_cursor = None

    if len(rows) > limit:
        rows = rows[:limit]
        last = rows[-1]
        next_cursor = encode_cursor(last[11], last[0])  # date_filed (index 11), id (index 0)

    for r in rows:
        member = Member(
            id=r[4],      # p.id as member_id
            name=r[5],    # p.full_name
            chamber=r[6], # p.chamber
            party=r[7],   # p.party
            state=r[8],   # p.state
            district=r[9], # p.district
        )
        amount = None
        if r[12] is not None or r[13] is not None:  # amount_min, amount_max
            amount = {"min": float(r[12]) if r[12] else None, "max": float(r[13]) if r[13] else None}

        items.append(
            TradeItem(
                id=r[0],        # t.id
                ticker=r[1],    # k.symbol
                company=r[2],   # k.company_name
                txn=r[3],       # t.transaction_type
                member=member,
                dateTraded=r[10], # date_traded
                dateFiled=r[11],  # date_filed
                amount=amount,
                assetType=r[14],  # t.asset_type
            )
        )

    return items, next_cursor


def member_by_id(conn, member_id: int):
    from models import Member

    sql = "SELECT id, full_name, chamber, party, state, district FROM politicians WHERE id = %s"
    with conn.cursor() as cur:
        cur.execute(sql, (member_id,))
        row = cur.fetchone()
    if not row:
        return None
    return Member(id=row[0], name=row[1], chamber=row[2], party=row[3], state=row[4], district=row[5])


def ticker_by_symbol(conn, symbol: str):
    from models import Ticker

    sql = "SELECT symbol, company_name FROM tickers WHERE symbol = %s"
    with conn.cursor() as cur:
        cur.execute(sql, (symbol,))
        row = cur.fetchone()
    if not row:
        return None
    return Ticker(symbol=row[0], company=row[1])


def trending_query(conn, limit: int, window_days: int) -> List[Tuple]:
    sql = """
    SELECT k.symbol,
           COUNT(*) as trade_count,
           SUM(CASE WHEN t.transaction_type = 'Buy' THEN 1 ELSE 0 END) as buy_count,
           SUM(CASE WHEN t.transaction_type = 'Sell' THEN 1 ELSE 0 END) as sell_count
    FROM trades t
    JOIN tickers k ON k.id = t.ticker_id
    WHERE t.date_filed >= CURRENT_DATE - INTERVAL %s
    GROUP BY k.symbol
    ORDER BY trade_count DESC
    LIMIT %s
    """
    with conn.cursor() as cur:
        cur.execute(sql, [f"{window_days} days", limit])
        return cur.fetchall()

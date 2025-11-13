from __future__ import annotations
from dataclasses import dataclass
from typing import Optional, Tuple


TXN_MAP = {
    "purchase": "Buy",
    "buy": "Buy",
    "acquisition": "Buy",
    "sale": "Sell",
    "sell": "Sell",
}

ASSET_MAP = {
    "stock": "Stock",
    "etf": "ETF",
    "mutual fund": "MutualFund",
    "option": "Option",
}


@dataclass
class NormalizedTrade:
    bioguide_id: Optional[str]
    member_name: str
    chamber: str
    party: Optional[str]
    state: Optional[str]
    district: Optional[str]
    raw_ticker: Optional[str]
    symbol: Optional[str]
    txn: str
    asset_type: Optional[str]
    date_traded: Optional[str]
    date_filed: Optional[str]
    amount_min: Optional[float]
    amount_max: Optional[float]
    source: str
    source_txn_id: str
    raw: dict


def normalize_record(r: dict) -> NormalizedTrade:
    member = r.get("Representative") or r.get("Senator") or r.get("Member") or r.get("Politician") or "Unknown"
    bioguide = r.get("BioguideID") or r.get("bioid")
    chamber = r.get("Chamber") or ("Senate" if r.get("Senator") else "House")
    party = r.get("Party")
    state = r.get("State")
    district = r.get("District")


    raw_ticker = r.get("Ticker") or r.get("Symbol")
    symbol = (raw_ticker or "").upper() if raw_ticker else None

    txn_raw = (r.get("Transaction") or r.get("Type") or r.get("TransactionType") or "").lower()
    txn = TXN_MAP.get(txn_raw, "Other")


    asset_raw = (r.get("AssetType") or r.get("Asset") or "").lower()
    asset = ASSET_MAP.get(asset_raw, None)


    date_traded = r.get("TransactionDate") or r.get("Date")
    date_filed = r.get("FilingDate") or r.get("ReportDate") or r.get("DateFiled")


    amt_min = r.get("AmountMin") or r.get("Low") or None
    amt_max = r.get("AmountMax") or r.get("High") or None


    source = r.get("Source") or "Quiver"
    source_id = str(r.get("id") or r.get("ID") or r.get("FilingId") or hash(str(r)))


    return NormalizedTrade(
        bioguide_id=bioguide,
        member_name=member,
        chamber=chamber,
        party=party,
        state=state,
        district=district,
        raw_ticker=raw_ticker,
        symbol=symbol,
        txn=txn,
        asset_type=asset,
        date_traded=date_traded,
        date_filed=date_filed,
        amount_min=to_float(amt_min),
        amount_max=to_float(amt_max),
        source=source,
        source_txn_id=source_id,
        raw=r,
    )


def to_float(v):
    try:
        if v is None or v == "":
            return None
        return float(v)
    except Exception:
        return None

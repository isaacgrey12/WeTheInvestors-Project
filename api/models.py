from __future__ import annotations
from pydantic import BaseModel
from typing import Optional, List


class Member(BaseModel):
    id: int
    name: str
    chamber: str
    party: Optional[str] = None
    state: Optional[str] = None
    district: Optional[str] = None


class TradeItem(BaseModel):
    id: int
    ticker: Optional[str]
    company: Optional[str]
    txn: str
    member: Member
    dateTraded: Optional[str]
    dateFiled: Optional[str]
    amount: Optional[dict]
    assetType: Optional[str]


class FeedResponse(BaseModel):
    items: List[TradeItem]
    nextCursor: Optional[str] = None


class Ticker(BaseModel):
    symbol: str
    company: Optional[str] = None

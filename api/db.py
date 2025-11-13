from __future__ import annotations
import os
import psycopg2
from psycopg2.pool import SimpleConnectionPool
from contextlib import contextmanager


_pool: SimpleConnectionPool | None = None




def init_pool(dsn: str):
    global _pool
    if _pool is None:
        _pool = SimpleConnectionPool(minconn=1, maxconn=10, dsn=dsn)
    return _pool




@contextmanager
def get_conn():
    if _pool is None:
        raise RuntimeError("DB pool not initialized")
    conn = _pool.getconn()
    try:
        yield conn
    finally:
        _pool.putconn(conn)

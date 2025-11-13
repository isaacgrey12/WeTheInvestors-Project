```md

# API Server (FastAPI)



## Setup

```bash

cd api

cp .env.example .env

# set DATABASE_URL to the same DB you used for ETL

python -m venv .venv && source .venv/bin/activate

pip install -r requirements.txt

./run.sh

```

## Endpoints

- `GET /health`
- `GET /v1/feed?limit=50&cursor=...&chamber=House|Senate&party=D|R|I&txn=Buy|Sell|Other&start=YYYY-MM-DD&end=YYYY-MM-DD&ticker=AAPL`
- `GET /v1/members/{id}`
- `GET /v1/members/{id}/trades?limit=&cursor=`
- `GET /v1/tickers/{symbol}`
- `GET /v1/tickers/{symbol}/trades?limit=&cursor=`
- `GET /v1/insights/trending?window=7&limit=20`

## Quick smoke tests

```bash

curl -s http://localhost:8080/health | jq

curl -s "http://localhost:8080/v1/feed?limit=5" | jq

curl -s "http://localhost:8080/v1/tickers/AAPL/trades?limit=5" | jq

```

> Pagination uses a stable `(date_filed, id)` seek. We fetch `limit+1` rows; if an extra exists, we return `nextCursor` encoded as base64 of `{date, id}`.
>

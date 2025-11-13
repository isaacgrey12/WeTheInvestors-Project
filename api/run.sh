#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
export $(grep -v '^#' .env | xargs -I{} echo {})
uvicorn main:app --host 0.0.0.0 --port "${PORT:-8080}" --reload
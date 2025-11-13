#!/usr/bin/env bash
set -euo pipefail
source .venv/bin/activate || true
python etl.py --since "14d" --limit 10000
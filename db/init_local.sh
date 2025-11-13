#!/usr/bin/env bash
set -euo pipefail


# You can override via env, e.g. DB_USER=$USER ./init_local.sh
DB_NAME=${DB_NAME:-congressdb}
DB_USER=${DB_USER:-postgres}
DB_PASS=${DB_PASS:-postgres}
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}


export PGPASSWORD="$DB_PASS"


# -- helper: test a login --
psql_try() {
    psql -h "$DB_HOST" -U "$1" -p "$DB_PORT" -d postgres -tc "SELECT 1" >/dev/null 2>&1
}


# If connecting as postgres via socket fails on macOS, force TCP with -h localhost (we already do).
# Detect an admin role we can use: prefer $DB_USER, else current $USER, else 'postgres'.
ADMIN_USER="$DB_USER"
if ! psql_try "$ADMIN_USER"; then
    if psql_try "$USER"; then
        ADMIN_USER="$USER"
    elif psql_try "postgres"; then
        ADMIN_USER="postgres"
    else
        echo "❌ Could not connect to Postgres with users: '$DB_USER', '$USER', or 'postgres'.
        Tip: ensure the server is running and that one of these roles exists with access on host $DB_HOST:$DB_PORT."
    exit 1
    fi
fi


# Create target DB if missing
psql -h "$DB_HOST" -U "$ADMIN_USER" -p "$DB_PORT" -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'" | grep -q 1 || \
    psql -h "$DB_HOST" -U "$ADMIN_USER" -p "$DB_PORT" -c "CREATE DATABASE \"$DB_NAME\";"


# Ensure 'postgres' superuser exists (handy for tools); ignore if it already exists
psql -h "$DB_HOST" -U "$ADMIN_USER" -p "$DB_PORT" -d postgres -tc "SELECT 1 FROM pg_roles WHERE rolname='postgres'" | grep -q 1 || \
    psql -h "$DB_HOST" -U "$ADMIN_USER" -p "$DB_PORT" -d postgres -c "CREATE ROLE postgres WITH LOGIN SUPERUSER PASSWORD '$DB_PASS';"


psql -h "$DB_HOST" -U "$ADMIN_USER" -p "$DB_PORT" -d "$DB_NAME" -f schema.sql
psql -h "$DB_HOST" -U "$ADMIN_USER" -p "$DB_PORT" -d "$DB_NAME" -f seed.sql || true
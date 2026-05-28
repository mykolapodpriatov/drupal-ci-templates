#!/usr/bin/env bash
#
# Poll a MySQL/MariaDB host until it accepts connections, or fail after a
# bounded number of attempts. Works against `mysqladmin` or `mariadb-admin`,
# whichever is on PATH.
#
# Usage:
#   ./scripts/wait-for-mysql.sh <host> <port> [max_attempts] [user] [password]
#
# Defaults: max_attempts=30, user=root, password=root.

set -euo pipefail

HOST="${1:-127.0.0.1}"
PORT="${2:-3306}"
MAX_ATTEMPTS="${3:-30}"
USER="${4:-root}"
PASSWORD="${5:-root}"

if command -v mariadb-admin >/dev/null 2>&1; then
  PING_CMD="mariadb-admin"
elif command -v mysqladmin >/dev/null 2>&1; then
  PING_CMD="mysqladmin"
else
  echo "ERROR: neither mariadb-admin nor mysqladmin is on PATH." >&2
  exit 1
fi

echo "==> Waiting for MySQL at ${HOST}:${PORT} (max ${MAX_ATTEMPTS} attempts)..."

attempt=1
while [ "$attempt" -le "$MAX_ATTEMPTS" ]; do
  if "$PING_CMD" ping --silent --host="$HOST" --port="$PORT" --user="$USER" --password="$PASSWORD" >/dev/null 2>&1; then
    echo "==> MySQL is up after ${attempt} attempt(s)."
    exit 0
  fi
  printf "."
  attempt=$((attempt + 1))
  sleep 2
done

echo
echo "ERROR: MySQL at ${HOST}:${PORT} did not become ready after ${MAX_ATTEMPTS} attempts." >&2
exit 1

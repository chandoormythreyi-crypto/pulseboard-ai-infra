#!/usr/bin/env bash
# One-time logical copy of the PulseBoard database into a target RDS.
#
# This is a point-in-time COPY, not a cutover or ongoing replication. It runs a
# `pg_dump | pg_restore` from SOURCE_DB_URL into TARGET_DB_URL. Both URLs must be
# reachable from wherever this runs; because both RDS instances live in private
# subnets (and, today, in different accounts), the usual path is two SSM
# port-forward sessions exposing each DB on localhost — see docs/db-copy-stage.md.
#
# Usage:
#   SOURCE_DB_URL='postgresql://user:pass@host:5432/db?sslmode=require' \
#   TARGET_DB_URL='postgresql://user:pass@host:5432/db?sslmode=require' \
#   scripts/copy-db.sh
#
# Env:
#   SOURCE_DB_URL   required  libpq URL of the DB to copy FROM
#   TARGET_DB_URL   required  libpq URL of the DB to copy INTO (created empty by Terraform)
#   DUMP_JOBS       optional  parallel pg_dump/restore jobs (default 4)
#   ASSUME_YES      optional  set to 1 to skip the confirmation prompt
set -euo pipefail

: "${SOURCE_DB_URL:?set SOURCE_DB_URL}"
: "${TARGET_DB_URL:?set TARGET_DB_URL}"
DUMP_JOBS="${DUMP_JOBS:-4}"

command -v pg_dump  >/dev/null || { echo "pg_dump not found (install postgresql client 16.x)"; exit 1; }
command -v pg_restore >/dev/null || { echo "pg_restore not found"; exit 1; }

redact() { sed -E 's#(://[^:]+:)[^@]+@#\1***@#'; }
echo "Source: $(echo "$SOURCE_DB_URL" | redact)"
echo "Target: $(echo "$TARGET_DB_URL" | redact)"

# Refuse to overwrite a target that already has application tables.
existing=$(psql "$TARGET_DB_URL" -tAc \
  "select count(*) from information_schema.tables where table_schema not in ('pg_catalog','information_schema');")
if [ "${existing:-0}" -ne 0 ]; then
  echo "Target already has ${existing} tables — refusing to copy into a non-empty DB." >&2
  echo "Drop/recreate the target database first if you really want to reseed it." >&2
  exit 1
fi

if [ "${ASSUME_YES:-0}" != "1" ]; then
  read -r -p "Copy ALL data from source into the (empty) target? [y/N] " ans
  [ "$ans" = "y" ] || [ "$ans" = "Y" ] || { echo "aborted"; exit 1; }
fi

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
dump="$workdir/pulseboard.dump"

echo "==> pg_dump (custom format, ${DUMP_JOBS} jobs)"
pg_dump --format=directory --jobs="$DUMP_JOBS" --no-owner --no-privileges \
  --file="$dump" "$SOURCE_DB_URL"

echo "==> pg_restore into target"
pg_restore --format=directory --jobs="$DUMP_JOBS" --no-owner --no-privileges \
  --exit-on-error --dbname="$TARGET_DB_URL" "$dump"

echo "==> verify row counts on a few tables"
psql "$TARGET_DB_URL" -c \
  "select schemaname, relname, n_live_tup
     from pg_stat_user_tables
    order by n_live_tup desc
    limit 10;"

echo "Copy complete."

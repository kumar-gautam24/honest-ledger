#!/usr/bin/env bash
#
# backup.sh — runs ON THE SERVER (nightly, via cron).
# Takes a consistent logical dump of the Postgres database, compresses it, and
# streams it straight to S3 with a timestamped key. No temp file touches local disk.
#
#   Manual run:  BACKUP_BUCKET=s3://your-bucket ./scripts/backup.sh
#   Cron sets BACKUP_BUCKET in the crontab line (see docs).
#
set -euo pipefail

# The off-site vault. MUST be overridden with your real, globally-unique bucket name.
BUCKET="${BACKUP_BUCKET:?set BACKUP_BUCKET, e.g. s3://recurring-backups-<unique>}"

STAMP="$(date -u +%Y-%m-%dT%H-%M-%SZ)"      # UTC so backups sort correctly everywhere
KEY="db/recurring-${STAMP}.sql.gz"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../backend"

echo "==> Dumping database and streaming to ${BUCKET%/}/${KEY} ..."
# pg_dump runs INSIDE the db container (-T = no TTY, required for pipes/cron).
# The dump is gzipped on the host and piped to S3 with `-` (stdin) — nothing lands on disk.
# pipefail (set above) makes the whole line fail if pg_dump OR gzip OR the upload fails.
docker compose exec -T db pg_dump -U recurring -d recurring \
  | gzip \
  | aws s3 cp - "${BUCKET%/}/${KEY}"

echo "OK: backup uploaded -> ${BUCKET%/}/${KEY}"

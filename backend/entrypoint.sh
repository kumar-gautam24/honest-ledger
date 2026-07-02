#!/usr/bin/env bash
# Container start: apply any new DB migrations, then start the API server.
# Running migrations here (not baked into the image) means the schema is brought
# up to date against whatever database this container is pointed at.
set -euo pipefail

echo "[entrypoint] applying migrations..."
yoyo apply --database "$DATABASE_URL" --batch ./migrations

echo "[entrypoint] starting uvicorn..."
exec uvicorn app.main:app --host 0.0.0.0 --port 8000

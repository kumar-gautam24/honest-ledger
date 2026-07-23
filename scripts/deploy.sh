#!/usr/bin/env bash
#
# deploy.sh — runs ON THE SERVER.
# Pulls the latest code, rebuilds the containers, restarts, and verifies health.
# Database migrations apply themselves on container start (entrypoint.sh -> yoyo apply),
# so there is no separate "run migrations" step.
#
#   Usage (on the server):  ./scripts/deploy.sh
#
set -euo pipefail

# Find the backend dir relative to this script, so it works no matter where you call it from.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../backend"

echo "==> Fetching latest refs (prune first)..."
# Prune stale remote-tracking refs and force-update tags BEFORE pulling. A leftover
# ref like origin/release/ios-1.0.0 collides with a new origin/release branch and makes
# plain `git pull` abort with "some local refs could not be updated" — which once wedged
# the whole deploy. Pruning clears that collision so a stray branch/tag can't jam us.
git fetch origin --prune --tags --force

echo "==> Fast-forwarding..."
# --ff-only refuses to create a merge commit. On a server that only *consumes* code,
# a pull that can't fast-forward means someone edited on the server — we want to fail loud.
git pull --ff-only

echo "==> Rebuilding & restarting (migrations auto-apply on boot)..."
docker compose up -d --build

echo "==> Waiting for the backend to report ready..."
for _ in $(seq 1 15); do
  if curl -fsS http://localhost:8000/ready >/dev/null 2>&1; then
    echo "OK: backend is ready."
    docker compose ps
    exit 0
  fi
  sleep 2
done

echo "FAILED: /ready did not come up in ~30s. Recent logs:"
docker compose logs --tail=40 api
docker compose ps
exit 1

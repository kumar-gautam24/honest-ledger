#!/usr/bin/env bash
#
# ship.sh — runs ON YOUR MAC.
# The whole laptop-to-server loop in one command: push your commits to GitHub,
# then SSH into the server and run its deploy.sh (which pulls + rebuilds + verifies).
#
#   Usage (on your Mac):  ./scripts/ship.sh
#
# If the server's public IP ever changes (it can, on stop/start), override without
# editing this file:
#   RECURRING_HOST=ubuntu@NEW.IP.HERE ./scripts/ship.sh
#
set -euo pipefail

KEY="${RECURRING_KEY:-$HOME/Downloads/recurring-key.pem}"
HOST="${RECURRING_HOST:-ubuntu@44.223.23.55}"
REMOTE_DIR="${RECURRING_REMOTE_DIR:-honest-ledger}"

echo "==> Pushing local commits to GitHub..."
git push

echo "==> Triggering deploy on the server ($HOST)..."
ssh -i "$KEY" "$HOST" "cd '$REMOTE_DIR' && ./scripts/deploy.sh"

echo "Shipped. Live at https://44-223-23-55.nip.io"

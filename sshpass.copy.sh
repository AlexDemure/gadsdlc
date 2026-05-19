#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ -f .env ]]; then
  set -a
  . ./.env
  set +a
fi

SERVER_HOST="${SERVER_HOST:?set SERVER_HOST in .env or env}"
SERVER_USER="${SERVER_USER:?set SERVER_USER in .env or env}"
SERVER_PASSWORD="${SERVER_PASSWORD:?set SERVER_PASSWORD in .env or env}"
REMOTE_DIR="${REMOTE_DIR:?set REMOTE_DIR in .env or env}"

sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "mkdir -p $REMOTE_DIR"
sshpass -p "$SERVER_PASSWORD" rsync -av --delete \
  --exclude '.idea' \
  --exclude '.volumes' \
  --exclude '.git' \
  -e "ssh -o StrictHostKeyChecking=no" \
  ./ "$SERVER_USER@$SERVER_HOST:$REMOTE_DIR/"
sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "chmod +x $REMOTE_DIR/server.install.sh $REMOTE_DIR/ssh.copy.sh $REMOTE_DIR/sshpass.copy.sh $REMOTE_DIR/.nginx/install.sh"

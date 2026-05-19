#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ ! -f .env ]]; then
  echo ".env is required"
  echo "create or transfer a ready .env file before running ./server.install.sh"
  exit 1
fi

set -a
. ./.env
set +a

mkdir -p \
  .volumes/gitlab/config \
  .volumes/gitlab/logs \
  .volumes/gitlab/data \
  .volumes/homarr/appdata \
  .volumes/outline/storage \
  .volumes/outline/postgres \
  .volumes/outline/redis \
  .volumes/kaneo/postgres \
  .volumes/seafile/mysql \
  .volumes/seafile/data \
  .volumes/zerobyte/data \
  .volumes/authentik/postgresql \
  .volumes/authentik/data \
  .volumes/authentik/custom-templates

chown -R 1000:1000 .volumes/authentik/data .volumes/authentik/custom-templates

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required"
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "docker compose is required"
  exit 1
fi

docker network inspect dcu-net >/dev/null 2>&1 || docker network create dcu-net

docker compose -f docker-compose.authentik.yml up -d
docker compose -f docker-compose.gitlab.yml up -d
docker compose -f docker-compose.outline.yml up -d
docker compose -f docker-compose.kaneo.yml up -d
docker compose -f docker-compose.homarr.yml up -d
docker compose -f docker-compose.seafile.yml up -d
docker compose -f docker-compose.zerobyte.yml up -d

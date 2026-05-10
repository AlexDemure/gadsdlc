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
  .volumes/traefik/letsencrypt \
  .volumes/zerobyte/data \
  .volumes/authentik/postgresql \
  .volumes/authentik/data \
  .volumes/authentik/custom-templates

chown -R 1000:1000 .volumes/authentik/data .volumes/authentik/custom-templates
touch .volumes/traefik/letsencrypt/acme.json
chmod 600 .volumes/traefik/letsencrypt/acme.json

if ! command -v docker >/dev/null 2>&1; then
  if command -v apt-get >/dev/null 2>&1; then
    apt-get update
    apt-get install -y ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    . /etc/os-release
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $VERSION_CODENAME stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    systemctl enable docker
    systemctl start docker
  elif command -v snap >/dev/null 2>&1; then
    snap install docker
  elif command -v dnf >/dev/null 2>&1; then
    dnf install -y dnf-plugins-core
    dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    systemctl enable docker
    systemctl start docker
  elif command -v yum >/dev/null 2>&1; then
    yum install -y yum-utils
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    systemctl enable docker
    systemctl start docker
  else
    echo "docker is not installed and no supported package manager was found"
    exit 1
  fi
fi

docker network inspect sdlc-net >/dev/null 2>&1 || docker network create sdlc-net

docker compose -f docker-compose.traefik.yml up -d
docker compose -f docker-compose.authentik.yml up -d
docker compose -f docker-compose.gitlab.yml up -d
docker compose -f docker-compose.outline.yml up -d
docker compose -f docker-compose.kaneo.yml up -d
docker compose -f docker-compose.homarr.yml up -d
docker compose -f docker-compose.seafile.yml up -d
docker compose -f docker-compose.zerobyte.yml up -d

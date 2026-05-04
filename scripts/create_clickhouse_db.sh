#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="${ROOT_DIR}/infra/compose/docker-compose.yml"
ENV_FILE="${ROOT_DIR}/infra/compose/.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing ${ENV_FILE}. Copy infra/compose/.env.example to infra/compose/.env first." >&2
  exit 1
fi

source "${ENV_FILE}"

DB_NAME="${CLICKHOUSE_DB:-stream_ads}"

docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" exec -T clickhouse \
  clickhouse-client \
  --query "CREATE DATABASE IF NOT EXISTS ${DB_NAME}"

echo "Ensured ClickHouse database ${DB_NAME} exists."

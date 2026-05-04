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

TOPIC="${INPUT_TOPIC:-ad-clicks-v1}"
DB_NAME="${CLICKHOUSE_DB:-stream_ads}"
BUCKET_NAME="${MINIO_RAW_BUCKET:-raw-events}"
MINIO_USER="${MINIO_ROOT_USER:-minioadmin}"
MINIO_PASSWORD="${MINIO_ROOT_PASSWORD:-minioadmin}"

ok() {
  echo "[ok] $1"
}

fail() {
  echo "[fail] $1" >&2
  exit 1
}

run_compose() {
  docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" "$@"
}

require_service_running() {
  local service="$1"

  run_compose ps --status running --services 2>/dev/null | grep -Fxq "${service}" \
    || fail "service ${service} is not running"
  ok "service ${service} is running"
}

check_http() {
  local name="$1"
  local url="$2"

  curl -fsS "${url}" >/dev/null || fail "${name} is not reachable at ${url}"
  ok "${name} is reachable at ${url}"
}

echo "Checking core service processes..."
require_service_running redpanda
require_service_running redpanda-console
require_service_running clickhouse
require_service_running redis
require_service_running minio
require_service_running flink-jobmanager
require_service_running flink-taskmanager

echo
echo "Checking service endpoints..."
check_http "Redpanda admin API" "http://localhost:${REDPANDA_ADMIN_PORT:-19644}/v1/status/ready"
check_http "Redpanda Console" "http://localhost:${REDPANDA_CONSOLE_PORT:-18080}"
check_http "Flink UI" "http://localhost:${FLINK_JOBMANAGER_PORT:-18081}/overview"
check_http "ClickHouse HTTP" "http://localhost:${CLICKHOUSE_HTTP_PORT:-18123}/ping"

run_compose exec -T redis redis-cli ping | rg -x "PONG" >/dev/null || fail "Redis did not return PONG"
ok "Redis responded to ping"

run_compose run --rm --entrypoint /bin/sh mc -lc "\
  mc alias set localminio http://minio:9000 ${MINIO_USER} ${MINIO_PASSWORD} >/dev/null && \
  mc ready localminio >/dev/null" || fail "MinIO is not ready through mc"
ok "MinIO is ready through mc"

echo
echo "Checking initialized assets..."
run_compose exec -T redpanda rpk topic describe "${TOPIC}" --brokers redpanda:9092 >/dev/null \
  || fail "topic ${TOPIC} does not exist"
ok "topic ${TOPIC} exists"

run_compose exec -T clickhouse clickhouse-client --query "EXISTS DATABASE ${DB_NAME}" | rg -x "1" >/dev/null \
  || fail "ClickHouse database ${DB_NAME} does not exist"
ok "ClickHouse database ${DB_NAME} exists"

run_compose run --rm --entrypoint /bin/sh mc -lc "\
  mc alias set localminio http://minio:9000 ${MINIO_USER} ${MINIO_PASSWORD} >/dev/null && \
  mc ls localminio/${BUCKET_NAME} >/dev/null" || fail "MinIO bucket ${BUCKET_NAME} does not exist"
ok "MinIO bucket ${BUCKET_NAME} exists"

echo
echo "Smoke test passed."

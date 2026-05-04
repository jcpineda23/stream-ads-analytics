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

MINIO_ALIAS="localminio"
BUCKET_NAME="${MINIO_RAW_BUCKET:-raw-events}"
MINIO_USER="${MINIO_ROOT_USER:-minioadmin}"
MINIO_PASSWORD="${MINIO_ROOT_PASSWORD:-minioadmin}"

docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" run --rm --entrypoint /bin/sh mc -lc "\
  mc alias set ${MINIO_ALIAS} http://minio:9000 ${MINIO_USER} ${MINIO_PASSWORD} >/dev/null && \
  mc mb --ignore-existing ${MINIO_ALIAS}/${BUCKET_NAME} >/dev/null && \
  echo 'Ensured MinIO bucket ${BUCKET_NAME} exists.'"

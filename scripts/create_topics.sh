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
PARTITIONS="${INPUT_TOPIC_PARTITIONS:-6}"
REPLICATION_FACTOR="${INPUT_TOPIC_REPLICATION_FACTOR:-1}"

if docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" exec -T redpanda \
  rpk topic describe "${TOPIC}" --brokers redpanda:9092 >/dev/null 2>&1; then
  echo "Topic ${TOPIC} already exists."
  exit 0
fi

docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" exec -T redpanda \
  rpk topic create "${TOPIC}" \
  --brokers redpanda:9092 \
  --partitions "${PARTITIONS}" \
  --replicas "${REPLICATION_FACTOR}"

echo "Created topic ${TOPIC}."

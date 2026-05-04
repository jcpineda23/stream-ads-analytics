#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash "${ROOT_DIR}/scripts/create_topics.sh"
bash "${ROOT_DIR}/scripts/create_clickhouse_db.sh"
bash "${ROOT_DIR}/scripts/create_minio_bucket.sh"

echo "Local stack initialization complete."

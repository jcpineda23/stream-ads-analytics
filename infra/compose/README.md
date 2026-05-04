# Local Infrastructure

This directory contains the local dependency stack for Phase 1.

## Included Services
- `redpanda`: Kafka-compatible event log
- `redpanda-console`: topic and cluster inspection UI
- `clickhouse`: analytical serving store
- `redis`: hot cache
- `minio`: object storage for raw event archival
- `flink-jobmanager`: Flink control plane and UI
- `flink-taskmanager`: Flink worker runtime

## Files
- `docker-compose.yml`: core local stack
- `.env.example`: default local configuration values

## Usage
1. Copy `.env.example` to `.env`
2. Start the stack:

```bash
docker compose -f infra/compose/docker-compose.yml --env-file infra/compose/.env up -d
```

3. Initialize runtime assets:

```bash
bash scripts/init_stack.sh
```

4. Run the smoke test:

```bash
bash scripts/check_stack.sh
```

Phase 1.4 will expand this into a fuller operator runbook with troubleshooting and reset procedures.

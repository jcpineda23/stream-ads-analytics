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

## Prerequisites
- Docker Desktop or a compatible local Docker runtime
- enough local resources to run Redpanda, Flink, ClickHouse, Redis, and MinIO together
- a copied environment file:

```bash
cp infra/compose/.env.example infra/compose/.env
```

## Startup
1. Start the stack:

```bash
docker compose -f infra/compose/docker-compose.yml --env-file infra/compose/.env up -d
```

2. Initialize runtime assets:

```bash
bash scripts/init_stack.sh
```

3. Run the smoke test:

```bash
bash scripts/check_stack.sh
```

## Endpoints
- Redpanda broker: `localhost:19092`
- Redpanda admin API: `http://localhost:19644`
- Redpanda Console: `http://localhost:18080`
- Flink UI: `http://localhost:18081`
- ClickHouse HTTP: `http://localhost:18123`
- ClickHouse native: `localhost:19000`
- Redis: `localhost:16379`
- MinIO API: `http://localhost:19010`
- MinIO Console: `http://localhost:19011`

## Runtime Assets
The initialization script creates:
- Redpanda topic: `ad-clicks-v1`
- ClickHouse database: `stream_ads`
- MinIO bucket: `raw-events`

These assets are expected to persist across a normal `docker compose down` and `up -d` cycle because the stack uses named Docker volumes.

## Validated Stability Behavior
Phase 1.5 verified:
- the full stack can be brought down and started again without rework,
- the smoke test passes after restart,
- the Redpanda topic, ClickHouse database, and MinIO bucket persist across restart,
- a ClickHouse sentinel row and MinIO sentinel object also persist across restart,
- host-to-container access paths work for Kafka, Redis, ClickHouse native, and MinIO HTTP.

## Common Commands
Stop containers without removing them:

```bash
docker compose -f infra/compose/docker-compose.yml --env-file infra/compose/.env stop
```

Remove containers and network but keep data volumes:

```bash
docker compose -f infra/compose/docker-compose.yml --env-file infra/compose/.env down
```

Reset the full local environment including persisted data:

```bash
docker compose -f infra/compose/docker-compose.yml --env-file infra/compose/.env down -v
```

Re-run initialization safely:

```bash
bash scripts/init_stack.sh
```

Re-run health validation:

```bash
bash scripts/check_stack.sh
```

## Known Limitations
- Redpanda runs as a single-node local cluster, so replication is intentionally minimal and not production-like.
- MinIO uses default local credentials in `.env.example` and should not be treated as secure.
- The Flink image currently runs as `linux/amd64`; on Apple Silicon or other `arm64` hosts this may use emulation and run slower.
- The app services for Phase 2 and later still run from the host/IDE rather than inside containers.
- The smoke test validates reachability and initialized assets, but it is not yet a substitute for producer or end-to-end stream correctness tests.

## Version Choices
- Redpanda: `v24.1.9`
- Redpanda Console: `v2.6.1`
- Flink: `1.19.1-scala_2.12-java17`
- ClickHouse: `24.3`
- Redis: `7.2-alpine`
- MinIO: `RELEASE.2024-03-26T22-10-45Z`

These versions are pinned in `docker-compose.yml` to keep local behavior predictable during the learning exercise.

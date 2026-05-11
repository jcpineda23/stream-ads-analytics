# Phase 1 Stability Pass

## Metadata
- Date: 2026-05-10
- Phase: 1
- Milestone: 1.5
- Test name: full stack restart and persistence validation
- Owner: Juan Pineda

## Objective
Validate that the local infrastructure stack is stable enough to support Phase 2 producer work without repeated infra churn.

## Environment
- Branch / commit: `main`
- Services running:
  - Redpanda
  - Redpanda Console
  - Flink JobManager
  - Flink TaskManager
  - ClickHouse
  - Redis
  - MinIO
- Relevant config:
  - topic: `ad-clicks-v1`
  - ClickHouse database: `stream_ads`
  - MinIO bucket: `raw-events`
- Input topic / database / bucket:
  - `ad-clicks-v1`
  - `stream_ads`
  - `raw-events`

## Commands
```bash
bash scripts/check_stack.sh

nc -z localhost 19092
nc -z localhost 16379
nc -z localhost 19000
curl -fsS http://localhost:19010/minio/health/live

docker compose -f infra/compose/docker-compose.yml --env-file infra/compose/.env exec -T clickhouse \
  clickhouse-client --multiquery --query "CREATE TABLE IF NOT EXISTS stream_ads.phase1_stability_sentinel (id String, note String) ENGINE = MergeTree ORDER BY id; INSERT INTO stream_ads.phase1_stability_sentinel VALUES ('phase1-2026-05-10', 'restart-persistence-check');"

docker compose -f infra/compose/docker-compose.yml --env-file infra/compose/.env run --rm --entrypoint /bin/sh mc -lc \
  "printf 'phase1-stability-sentinel\n' >/tmp/sentinel.txt && mc alias set localminio http://minio:9000 minioadmin minioadmin >/dev/null && mc cp /tmp/sentinel.txt localminio/raw-events/phase1-stability/sentinel.txt >/dev/null"

docker compose -f infra/compose/docker-compose.yml --env-file infra/compose/.env down
docker compose -f infra/compose/docker-compose.yml --env-file infra/compose/.env up -d

bash scripts/check_stack.sh

docker compose -f infra/compose/docker-compose.yml --env-file infra/compose/.env exec -T clickhouse \
  clickhouse-client --query "SELECT count() FROM stream_ads.phase1_stability_sentinel WHERE id = 'phase1-2026-05-10'"

docker compose -f infra/compose/docker-compose.yml --env-file infra/compose/.env run --rm --entrypoint /bin/sh mc -lc \
  "mc alias set localminio http://minio:9000 minioadmin minioadmin >/dev/null && mc ls localminio/raw-events/phase1-stability/sentinel.txt >/dev/null"
```

## Expected Result
- smoke test passes before and after restart
- Kafka, Redis, ClickHouse native, and MinIO host paths are reachable
- topic, database, and bucket survive restart
- sentinel row and sentinel object survive restart

## Actual Result
- smoke test passed before restart
- host connectivity checks passed for Kafka, Redis, ClickHouse native, and MinIO HTTP
- smoke test passed after restart
- topic `ad-clicks-v1` still existed after restart
- ClickHouse database `stream_ads` still existed after restart
- MinIO bucket `raw-events` still existed after restart
- ClickHouse sentinel row count after restart: `1`
- MinIO sentinel object still existed after restart

## Key Evidence
- logs:
  - stack was cleanly torn down with `docker compose down`
  - stack came back up successfully with `docker compose up -d`
- metrics:
  - persistence validated through sentinel existence, not only service health
- screenshots or UI observations:
  - Flink UI and Redpanda Console were reachable after restart

## Outcome
- Pass / Fail: Pass

## Design Lessons
- What we expected:
  - named Docker volumes would preserve topic metadata, database state, and bucket contents across a normal restart.
- What actually happened:
  - the persisted state survived the full stack cycle as expected, and the smoke test passed again after startup.
- What this means architecturally:
  - the local platform is stable enough to support host-run producer development without re-initializing core infrastructure each time.
- What we would change in production:
  - use native `arm64` Flink images where possible, stronger credential handling, and a more production-like Kafka topology with replication.

## Next Actions
- treat Phase 1 infrastructure as stable enough for Phase 2 producer work
- begin producer scaffold and valid event generation
- continue recording evidence for each producer test run

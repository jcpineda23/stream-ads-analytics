# Phase 1 Milestone 5 Report

## Metadata
- Date: 2026-05-10
- Phase: 1
- Milestone: 1.5
- Status: complete

## Goal
Harden the local environment enough that Phase 2 can focus on producer implementation rather than infrastructure instability.

## What We Built
- expanded the local infra README into an operator-style runbook
- documented endpoints, startup flow, runtime assets, restart behavior, cleanup commands, known limitations, and pinned versions
- executed a full restart and persistence validation against the running stack

## What We Tested
- baseline smoke test before restart
- host connectivity to Kafka, Redis, ClickHouse native, and MinIO
- persistence of initialized assets across `docker compose down` and `up -d`
- persistence of a ClickHouse sentinel row
- persistence of a MinIO sentinel object

## Results
- all core services restarted successfully
- the smoke test passed after restart
- the Redpanda topic, ClickHouse database, and MinIO bucket persisted
- explicit persistence sentinels survived restart
- one notable limitation remains:
  - the Flink image runs under `amd64` emulation on this host platform

## Evidence Links
- test runs:
  - [2026-05-10-phase-1-stability-pass.md](/Users/jcpineda/Code/stream-ads-analytics/evidence/phase-1/2026-05-10-phase-1-stability-pass.md)
- related docs:
  - [infra/compose/README.md](/Users/jcpineda/Code/stream-ads-analytics/infra/compose/README.md)
  - [docs/milestone-1-plan.md](/Users/jcpineda/Code/stream-ads-analytics/docs/milestone-1-plan.md)
- related scripts or code:
  - [scripts/check_stack.sh](/Users/jcpineda/Code/stream-ads-analytics/scripts/check_stack.sh)
  - [scripts/init_stack.sh](/Users/jcpineda/Code/stream-ads-analytics/scripts/init_stack.sh)

## Risks And Gaps
- Flink image architecture mismatch may affect local performance on `arm64` hosts
- the smoke test still validates platform readiness rather than end-to-end event correctness
- the producer and query API still run outside containers, which is acceptable for now but not production-like

## Design Lessons
- What we expected:
  - the stack would be stable enough for Phase 2 after basic health checks and initialization.
- What actually happened:
  - the stack was stable, but the restart exercise surfaced a useful platform-specific concern around Flink image architecture.
- What this tells us about the architecture:
  - the separation between durable storage, stream runtime, and serving layers is already useful even in local development because each layer can be validated independently.
- What we would change in production:
  - run native images for the host architecture, use non-default credentials, and move beyond a single-broker local topology.

## Recommendation For The Next Step
- move into Phase 2
- start with a producer scaffold and valid event generation
- keep recording throughput, skew, duplicate, and lateness experiments in `evidence/phase-2/`

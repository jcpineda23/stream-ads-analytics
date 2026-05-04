# Real-Time Ad Click Analytics Project Plan

## Summary
Build a high-throughput streaming analytics system for ad clicks. The system should ingest events continuously, deduplicate repeated clicks, aggregate metrics in event-time windows, compute Top-K trending ads and campaigns, and serve fresh results to downstream dashboards and APIs.

This is the best learning project for streaming systems because it combines nearly every important concept in one design:
- sustained high-throughput ingestion,
- partitioning and hot-key handling,
- stateful stream processing,
- watermarks and late-event handling,
- deduplication and replay safety,
- Top-K or heavy-hitter computation,
- low-latency serving of pre-aggregated results.

## Project Goal
Create a portfolio-quality system that demonstrates the practical engineering tradeoffs behind a production-grade streaming platform.

Primary outcomes:
- understand how event logs, stream processors, and analytical stores work together,
- learn how to model correctness under at-least-once delivery and replay,
- practice designing for throughput, skew, and observability,
- produce a project you can explain in a staff-level system design interview.

## Recommended Scenario
Use **real-time ad click aggregation with trending Top-K views** as the primary scenario.

Why this scenario is stronger than a pure "Top K liked videos" project:
- it still includes Top-K computation,
- it adds realistic concerns like duplicates and click skew,
- it naturally requires time-windowed aggregation,
- it introduces dimensions such as campaign, country, device, and publisher,
- it gives you a more credible path to replay, backfill, and fraud filtering extensions.

## Scope
The system should support:
- ingesting click events from multiple producers,
- durable event storage in an append-only log,
- real-time windowed aggregation by `campaign_id`, `ad_id`, `country`, and `device_type`,
- deduplication by `click_id`,
- Top-K trending ads and campaigns for windows such as 1 minute, 5 minutes, and 1 hour,
- low-latency query serving,
- replay from raw data to rebuild state.

Out of scope for v1:
- billing accuracy guarantees,
- exactly-once end-to-end across every sink,
- multi-region failover,
- advanced fraud detection,
- user-level attribution joins.

## Suggested Stack
For a strong industry-style implementation:
- `Kafka` or `Redpanda` for the durable event log
- `Flink` for stateful stream processing
- `ClickHouse` for analytical query serving
- `Redis` for hot Top-K leaderboard reads
- `MinIO` or `S3` for raw event archival and replay
- `Prometheus` and `Grafana` for metrics and dashboards
- `Go` or `Java` for producer and query services

Recommended default:
- `Redpanda + Flink + ClickHouse + Redis + MinIO`

This gives you the right architecture shape with less local setup friction than a full cloud deployment.

## Initial Event Schema
```json
{
  "click_id": "uuid",
  "event_time": 1714580000,
  "ingest_time": 1714580003,
  "user_id": "u123",
  "ad_id": "a456",
  "campaign_id": "c789",
  "publisher_id": "p321",
  "country": "US",
  "device_type": "mobile",
  "cost_micros": 1200
}
```

Required properties:
- `click_id` must be unique per click for dedupe,
- `event_time` is the event-time source for windows,
- `campaign_id` and `ad_id` should have skewed distributions during load tests,
- `country` and `device_type` give enough dimensionality for realistic queries.

## Scale Target
Start with a target that is serious but still runnable locally with throttled load.

Baseline assumptions:
- target logical throughput: `100,000` events/sec,
- burst target: `500,000` events/sec,
- freshness target: `p95 < 5s` from ingest to query visibility,
- replay capability for at least one historical partition,
- window support for 1 minute, 5 minute, and 1 hour views.

Local development reality:
- run lower throughput locally,
- preserve the same architecture and scaling assumptions in the design,
- use synthetic data to simulate skew and burst patterns.

## Architecture
```text
Event Producers
  -> Kafka / Redpanda topic
  -> Flink streaming job
     -> dedupe stage
     -> event-time windowed aggregation stage
     -> Top-K computation stage
  -> ClickHouse aggregate tables
  -> Redis leaderboard cache
  -> MinIO raw archive
  -> Query API / dashboard
```

## Core Design Decisions
### 1. Event log first
Use Kafka or Redpanda as the source of truth for the hot path. This enables:
- replay,
- consumer isolation,
- buffering during downstream slowdowns,
- operational visibility into lag and partitions.

### 2. Event-time processing
Use event-time windows, not processing-time windows. This forces you to reason about:
- late arrivals,
- watermarks,
- out-of-order data,
- bounded correctness windows.

### 3. Stateful stream processor
Use Flink because it gives you:
- keyed state,
- checkpointing,
- timers and windowing,
- a production-grade model for recovery and backpressure.

### 4. Separate serving from stream state
Do not serve all user queries directly from Flink state. Persist aggregates into ClickHouse and cache the hottest leaderboard results in Redis.

### 5. Design for replay
Archive raw events so you can rebuild aggregates after schema changes or logic bugs. Replay is one of the best learning exercises in the entire project.

## Main Functional Flows
### Ingestion flow
1. Producers generate click events and publish them to Kafka or Redpanda.
2. Events are partitioned, ideally by a stable key such as `campaign_id` or `ad_id`.
3. Raw events are also archived to object storage for replay.

### Processing flow
1. Flink consumes the click stream.
2. The job deduplicates events using `click_id`.
3. The job applies event-time watermarks.
4. Windowed aggregations compute counts and cost by dimensions.
5. A Top-K stage computes trending ads and campaigns.
6. Aggregates are written to ClickHouse and hot Top-K results are written to Redis.

### Query flow
1. A query API reads aggregate tables from ClickHouse.
2. The API reads leaderboard results from Redis for the hottest requests.
3. Dashboards poll the API at short intervals.

## Important Engineering Problems To Exercise
The value of this project comes from intentionally solving the hard parts:

### Deduplication
Clicks may be retried or replayed. Dedupe by `click_id` using a bounded state retention policy.

### Hot partitions
A single campaign or ad may dominate traffic. You should simulate hot keys and document mitigation strategies such as:
- key salting for intermediate aggregation,
- two-stage aggregation,
- partition count tuning,
- adaptive load generation.

### Late and out-of-order events
Not all events arrive in order. Add:
- watermarks,
- allowed lateness,
- a side output or dead-letter path for very late events.

### Replay and correctness
The system should support rebuilding aggregates from historical data without silently double counting.

### Top-K strategy
Start with exact Top-K in each window. Later, compare it with approximate heavy-hitter techniques such as Count-Min Sketch plus heap.

## Milestone Plan
### Phase 0: Design and setup
Deliverables:
- project plan document,
- event schema document,
- initial architecture diagram,
- local folder structure,
- selected stack and rationale.

### Phase 1: Local infrastructure
Deliverables:
- Docker Compose for Redpanda, Flink, ClickHouse, Redis, and MinIO,
- basic environment bootstrap instructions,
- health check script for all local dependencies.

Success criteria:
- all services start locally,
- ClickHouse and Redis are reachable,
- Kafka or Redpanda topic creation works,
- Flink job manager and task manager are healthy.

### Phase 2: Event producer
Deliverables:
- synthetic event generator,
- support for configurable throughput and skew,
- realistic payload generation,
- ability to inject duplicates and late events.

Success criteria:
- events are published continuously,
- throughput and skew are visible in metrics,
- producer can simulate hot campaigns and delayed events.

### Phase 3: Minimal streaming pipeline
Deliverables:
- Flink job that reads the input topic,
- basic event parsing and validation,
- 1-minute windowed aggregate by `campaign_id`,
- ClickHouse sink for aggregate results.

Success criteria:
- end-to-end data appears in ClickHouse,
- simple aggregate queries return correct results,
- the pipeline survives restarts with checkpoints enabled.

### Phase 4: Dedupe and event-time correctness
Deliverables:
- dedupe by `click_id`,
- event-time windows,
- watermark strategy,
- late-event handling policy.

Success criteria:
- duplicates do not inflate counts,
- out-of-order events are handled as expected,
- very late events are visible in metrics or side outputs.

### Phase 5: Top-K and serving
Deliverables:
- Top-K ads and campaigns by rolling window,
- Redis caching for leaderboard endpoints,
- query API for dashboard use cases.

Success criteria:
- API can return current Top-K within freshness targets,
- Redis serves hot queries quickly,
- ClickHouse remains the source for broader analytics queries.

### Phase 6: Observability and load validation
Deliverables:
- dashboards for throughput, lag, checkpoint duration, and sink latency,
- load-testing scripts,
- failure scenarios and notes.

Success criteria:
- you can explain bottlenecks with metrics,
- skew and lag are visible,
- replay and recovery behavior are documented.

### Phase 7: Interview-grade polish
Deliverables:
- architecture decision records,
- replay walkthrough,
- tradeoff writeup,
- demo script and sample queries.

Success criteria:
- you can present the system crisply at multiple abstraction levels,
- you can explain why each major technology choice was made,
- you can discuss correctness and operational tradeoffs with confidence.

## Initial Folder Plan
```text
stream-ads-analytics/
  docs/
    project-plan.md
    architecture.md
    milestones.md
  infra/
    docker/
    compose/
  services/
    producer/
    query-api/
  streaming/
    flink-job/
  scripts/
```

## First Build Order
Build in this order:
1. local infra
2. producer
3. minimal Flink aggregate
4. ClickHouse sink
5. query API
6. dedupe and event-time correctness
7. Top-K and replay

This keeps the project thin-sliced and prevents spending too much time on advanced features before the data path works end to end.

## Risks and Common Mistakes
- overbuilding infra before the first working pipeline exists,
- choosing too many technologies at once,
- skipping replay design until late,
- treating processing-time as good enough,
- ignoring hot-key skew during load generation,
- trying to make every component exactly-once in v1.

## Definition of Done For V1
V1 is complete when you can:
- generate continuous click traffic,
- aggregate real-time campaign counts in Flink,
- serve results through ClickHouse and an API,
- compute Top-K for at least one rolling window,
- show how duplicates and late events are handled,
- replay raw data and rebuild results.

## Next Documents To Add
- `docs/architecture.md`: component responsibilities and data flow
- `docs/event-schema.md`: schema versioning and validation rules
- `docs/milestones.md`: weekly execution checklist
- `infra/compose/README.md`: local stack startup instructions

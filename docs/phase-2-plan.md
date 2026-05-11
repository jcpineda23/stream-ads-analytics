# Phase 2 Plan: Synthetic Producer

## Objective
Build a synthetic event producer that generates realistic, controllable `ad_click.v1` traffic for the streaming platform.

Phase 2 should end with a producer that:
- continuously publishes valid events into `ad-clicks-v1`,
- supports controllable throughput,
- can simulate hot partitions through skewed campaign traffic,
- can inject duplicates and late events for later correctness testing.

## Why Phase 2 Matters
This phase creates the input pressure and failure modes that make the rest of the project meaningful.

Without a realistic producer:
- Phase 3 aggregation remains a toy demo,
- Phase 4 dedupe and watermarking cannot be stressed properly,
- Phase 5 Top-K logic cannot be evaluated under skew,
- Phase 6 load validation has no credible source workload.

## Recommended Implementation Choice
Recommended runtime:
- `Go`

Why:
- fast local iteration,
- straightforward Kafka-compatible client options,
- easy concurrency for rate control,
- good fit for a standalone producer service.

Alternative:
- `Java`

Use Java only if you want stronger language alignment with the future Flink implementation and are comfortable with a heavier local dev loop.

## Scope
In scope:
- producer service scaffold
- config loading
- Redpanda connectivity
- valid event generation
- rate and skew controls
- duplicate and late-event injection
- basic producer counters and logs
- evidence and milestone reports for key runs

Out of scope:
- Flink stream processing logic
- ClickHouse sink logic
- query API behavior
- dashboards beyond simple producer logs and counters

## Deliverables
- `services/producer/`
- producer README
- configuration file or env-driven runtime config
- commands for fixed-rate and skewed runs
- test records in `evidence/phase-2/`
- one milestone report summarizing producer behavior and lessons

## Phase 2 Milestones
### Milestone 2.1: Producer scaffold
Goal:
- create the producer project, local run command, config loading, and Redpanda connection.

Deliverables:
- runtime skeleton
- dependency setup
- basic config structure
- connection test path

Exit criteria:
- producer starts locally,
- config is loaded successfully,
- a connection to `localhost:19092` is established.

### Milestone 2.2: Valid event generation
Goal:
- emit valid `ad_click.v1` events that match the documented schema.

Deliverables:
- event model
- ID generation
- realistic dimension pools
- serializer

Exit criteria:
- events are published continuously at a low fixed rate,
- sample payloads match [event-schema.md](/Users/jcpineda/Code/stream-ads-analytics/docs/event-schema.md),
- the topic receives events without manual intervention.

### Milestone 2.3: Throughput and skew controls
Goal:
- turn the producer into a controllable workload generator instead of a fixed demo sender.

Deliverables:
- configurable events-per-second
- burst mode or rate ramping
- hot campaign and hot ad controls
- deterministic or seeded generation options

Exit criteria:
- rate can be adjusted without code changes,
- a small set of campaigns can dominate traffic on demand,
- generated traffic can model both even and skewed distributions.

### Milestone 2.4: Duplicate and late-event injection
Goal:
- produce the adversarial conditions needed for correctness work in later phases.

Deliverables:
- duplicate injection controls
- late-event injection controls
- event-time offset logic
- counters for normal, duplicate, and late events

Exit criteria:
- duplicates can be injected at a configurable rate,
- late events can be injected with a configurable delay profile,
- the producer logs enough counters to explain what it emitted.

### Milestone 2.5: Evidence and milestone report
Goal:
- document what was observed so the producer work becomes an interview asset, not just code.

Deliverables:
- at least one low-rate validation record
- at least one skew experiment record
- one milestone report summarizing design lessons

Exit criteria:
- `evidence/phase-2/` contains real test records,
- the milestone report explains the workload model, tradeoffs, and known gaps.

## Suggested Execution Order
1. 2.1 producer scaffold
2. 2.2 valid event generation
3. 2.5 first low-rate test record
4. 2.3 throughput and skew controls
5. 2.4 duplicate and late-event injection
6. 2.5 milestone report

## Early Test Plan
First validation runs should be simple and fast:

### Test A: low fixed-rate publish
- objective: prove the producer can publish valid events steadily
- rate: low
- duplicates: off
- lateness: off
- expected outcome: stable publishing with schema-valid payloads

### Test B: hot campaign skew
- objective: prove the producer can create partition imbalance intentionally
- rate: moderate
- duplicates: off
- lateness: off
- expected outcome: most traffic maps to a small campaign set

### Test C: duplicate injection
- objective: create future input for dedupe validation
- rate: low to moderate
- duplicates: on
- lateness: off
- expected outcome: duplicate count is visible in producer counters

### Test D: late-event injection
- objective: create future input for watermark and lateness handling
- rate: low to moderate
- duplicates: optional
- lateness: on
- expected outcome: emitted events include older `event_time` values by a controlled amount

## Configuration Themes
The producer should expose controls such as:
- broker address
- topic name
- events per second
- total runtime or infinite mode
- campaign count
- ad count
- hot campaign ratio
- duplicate rate
- late-event rate
- maximum lateness offset
- random seed

## Interview-Focused Design Lessons To Capture
During Phase 2, record lessons around:
- how skew affects partition strategy
- why synthetic data quality matters
- the difference between valid payloads and useful workloads
- what producer-side metrics are enough for debugging
- what you would change for a multi-tenant or higher-scale workload generator

## Definition Of Done
Phase 2 is complete when:
- the producer publishes valid `ad_click.v1` events continuously,
- throughput is configurable,
- skew can be introduced deliberately,
- duplicates and late events can be emitted deliberately,
- evidence exists for at least one validation run and one stress-style run.

## Recommended Next Step
Start with **Milestones 2.1 and 2.2 together**.

That gets us to the first real vertical slice quickly:
- producer process starts,
- producer connects to Redpanda,
- valid events begin flowing,
- the first `evidence/phase-2/` test record can be written immediately.

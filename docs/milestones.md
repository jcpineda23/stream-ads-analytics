# Milestones

## Phase 0
- status: complete
- create project structure
- write the initial plan
- confirm stack choices
- document event schema
- document architecture and data flow
- define Milestone 1 scope and exit criteria

## Phase 1
- status: planned
- bring up local infrastructure
- verify health checks
- document local startup flow
- create topic and bucket bootstrap scripts
- validate host-to-container connectivity for all core services
- Milestone 1.1: compose foundation, complete
- Milestone 1.2: service initialization, complete
- Milestone 1.3: health and smoke tests, complete
- Milestone 1.4: developer bootstrap documentation
- Milestone 1.5: stability pass

## Phase 2
- status: planned
- implement synthetic producer
- support throughput, duplicates, and skew controls
- produce test records and milestone reports in `evidence/phase-2/`

## Phase 3
- status: planned
- implement first Flink aggregation
- persist aggregates to ClickHouse
- produce test records and milestone reports in `evidence/phase-3/`

## Phase 4
- status: planned
- add dedupe and event-time handling
- validate late-event behavior
- produce test records and milestone reports in `evidence/phase-4/`

## Phase 5
- status: planned
- add Top-K and query API
- introduce Redis caching
- produce test records and milestone reports in `evidence/phase-5/`

## Phase 6
- status: planned
- add dashboards and load validation
- document bottlenecks and tradeoffs
- produce test records and milestone reports in `evidence/phase-6/`

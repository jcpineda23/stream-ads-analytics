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

## Phase 3
- status: planned
- implement first Flink aggregation
- persist aggregates to ClickHouse

## Phase 4
- status: planned
- add dedupe and event-time handling
- validate late-event behavior

## Phase 5
- status: planned
- add Top-K and query API
- introduce Redis caching

## Phase 6
- status: planned
- add dashboards and load validation
- document bottlenecks and tradeoffs

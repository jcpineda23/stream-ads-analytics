# Stream Ads Analytics

Hands-on system design and implementation project for a high-throughput streaming analytics platform.

## Goal
Build a real-time ad click aggregation system that:
- ingests high-volume click events,
- deduplicates them,
- computes windowed aggregates,
- produces Top-K trending ads and campaigns,
- serves low-latency analytics queries,
- supports replay and recovery from the raw event log.

## Workspace Layout
- `docs/`: architecture, plans, decisions, and runbooks
- `infra/`: local infrastructure such as Docker Compose and environment bootstrap
- `services/`: producer, query API, and supporting services
- `streaming/`: Flink jobs or other stream processing code
- `scripts/`: local developer and data generation scripts

## First Milestone
The first milestone is docs-first:
- define the product and system scope,
- lock the event schema,
- set scale assumptions and SLOs,
- agree on the implementation phases.

## Current Status
- Milestone 0: complete
- Milestone 1: complete
- Phase 2: planned in `docs/phase-2-plan.md`

## Key Docs
- `docs/architecture.md`: high-level system overview
- `docs/data-flow.md`: end-to-end event lifecycle and replay story
- `docs/deployment.md`: local and production-style deployment views
- `docs/testing-and-reporting.md`: how to record experiments and milestone outcomes
- `docs/phase-2-plan.md`: synthetic producer scope, milestones, and test strategy

## Evidence
- `evidence/`: test runs, milestone reports, and interview-ready learning records

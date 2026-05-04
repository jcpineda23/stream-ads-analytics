# Milestone 1 Plan: Local Infrastructure

## Objective
Stand up the local platform dependencies for the streaming system so that later milestones can focus entirely on application code and data flow.

Milestone 1 should end with a healthy local stack that supports:
- producing to Redpanda,
- running a Flink job,
- writing to ClickHouse,
- caching in Redis,
- archiving to MinIO.

## Scope
In scope:
- Docker Compose stack,
- baseline service configuration,
- persistent local volumes,
- health checks,
- bootstrap documentation,
- basic smoke-test scripts.

Out of scope:
- producer implementation,
- Flink business logic,
- full query API,
- dashboards beyond basic service health.

## Deliverables
- `infra/compose/docker-compose.yml`
- `infra/compose/.env.example`
- `infra/compose/README.md`
- `scripts/check_stack.sh`
- `scripts/create_topics.sh`
- optional bucket/bootstrap helper scripts

## Phase 1 Milestones
Phase 1 is best executed as five smaller internal milestones. Each one leaves the repo in a usable state and gives us a natural approval point before moving on.

### Milestone 1.1: Compose foundation
Status:
- complete

Goal:
- create the local infra skeleton and bring up the core services with predictable names, ports, and volumes.

In scope:
- `docker-compose.yml`
- `.env.example`
- shared network and named volumes
- base service definitions for Redpanda, ClickHouse, Redis, MinIO, and Flink

Exit criteria:
- `docker compose up -d` succeeds,
- all containers remain healthy after startup,
- host machine can reach the documented ports.

Key risk:
- misconfigured networking or advertised listeners causing services to appear healthy but remain unusable from the host.

### Milestone 1.2: Service initialization
Status:
- complete

Goal:
- make the stack actually usable by initializing the minimum required runtime assets.

In scope:
- topic bootstrap script,
- MinIO bucket creation flow,
- ClickHouse database creation flow,
- any one-time setup helpers needed for local startup.

Exit criteria:
- `ad-clicks-v1` topic exists,
- `stream_ads` database exists,
- `raw-events` bucket exists,
- setup can be repeated safely without breaking the environment.

Key risk:
- bootstrap steps becoming manual tribal knowledge instead of repeatable scripts.

### Milestone 1.3: Health and smoke tests
Status:
- complete

Goal:
- verify every core dependency from the host machine with one fast command path.

In scope:
- `scripts/check_stack.sh`
- reachability checks for Redpanda, ClickHouse, Redis, MinIO, and Flink UI
- failure messages that are easy to interpret

Exit criteria:
- one smoke-test command validates the full local platform,
- failure output identifies which dependency is unhealthy.

Key risk:
- shallow checks that prove ports are open but not that the services are actually usable.

### Milestone 1.4: Developer bootstrap documentation
Status:
- planned

Goal:
- make the local infra self-service for future work.

In scope:
- `infra/compose/README.md`
- prerequisites
- startup steps
- bootstrap steps
- health-check commands
- cleanup and reset instructions

Exit criteria:
- a new developer can follow the README and reach a healthy local stack without extra guidance.

Key risk:
- docs diverging from the actual commands if we don’t keep them close to the scripts.

### Milestone 1.5: Stability pass
Status:
- planned

Goal:
- harden the local environment enough that Phase 2 can focus on producer code instead of infra churn.

In scope:
- test restart behavior,
- verify data persists where expected,
- confirm host-to-container connectivity from future app paths,
- document known limitations and version choices.

Exit criteria:
- stack can be stopped and started without rework,
- core setup survives restart or has documented reset steps,
- known issues are captured explicitly.

Key risk:
- moving to Phase 2 before the environment is stable, which usually slows every later milestone.

## Approval Sequence
Use these as the step-by-step approval gates:
1. complete Milestone 1.1 by creating the Compose foundation files
2. complete Milestone 1.2 by adding bootstrap scripts and initialization helpers
3. complete Milestone 1.3 by adding smoke-test scripts
4. approve Milestone 1.4 to write the operator-style README
5. approve Milestone 1.5 to do the stabilization pass

If you want the fastest path, we can also batch Milestones 1.1 through 1.3 together and then pause for review before docs and stabilization.

## Proposed Services
### Redpanda
Purpose:
- input topic storage,
- replayable event log,
- consumer lag and partition visibility.

### Flink JobManager and TaskManager
Purpose:
- local runtime for stream-processing jobs,
- checkpointing and event-time experimentation.

### ClickHouse
Purpose:
- analytical serving store for windowed aggregates.

### Redis
Purpose:
- hot leaderboard cache.

### MinIO
Purpose:
- local object store for raw-event archival and replay testing.

## Target Directory Layout
```text
infra/
  compose/
    docker-compose.yml
    .env.example
    README.md
```

## Execution Plan
### Task 1: Compose stack skeleton
Create the base Compose file with:
- network definitions,
- named volumes,
- explicit ports,
- stable service names,
- restart policy suitable for local development.

Acceptance criteria:
- `docker compose up -d` starts all infra containers,
- service names are predictable and easy to reference from app code.

### Task 2: Redpanda configuration
Configure:
- a single-broker local Redpanda node,
- advertised listeners suitable for local development,
- admin or console access only if it stays simple.

Acceptance criteria:
- local scripts can create the `ad-clicks-v1` topic,
- basic topic listing works,
- producers can connect from the host machine.

### Task 3: Flink runtime wiring
Configure:
- one JobManager,
- one or more TaskManagers,
- local checkpoint directory wiring,
- exposed web UI port.

Acceptance criteria:
- Flink UI is reachable,
- a sample job can be submitted later without changing infra wiring.

### Task 4: ClickHouse baseline
Configure:
- exposed HTTP and native ports,
- a default database for the project,
- persistent storage volume.

Acceptance criteria:
- `clickhouse-client` or HTTP queries succeed,
- database creation and basic table creation are documented.

### Task 5: Redis baseline
Configure:
- exposed Redis port,
- a persistent or ephemeral mode documented explicitly.

Acceptance criteria:
- local `redis-cli ping` works,
- service is reachable from host and containers.

### Task 6: MinIO baseline
Configure:
- S3-compatible API port,
- console port,
- persistent storage volume,
- default bucket creation plan.

Acceptance criteria:
- bucket creation flow is documented,
- local scripts can reference a raw archive bucket such as `raw-events`.

### Task 7: Bootstrap documentation
Write a clear startup guide that covers:
- prerequisites,
- bring-up steps,
- service endpoints,
- common failure modes,
- cleanup commands.

Acceptance criteria:
- a new developer can bring the stack up without tribal knowledge.

### Task 8: Smoke-test scripts
Add scripts that verify:
- Redpanda topic operations,
- ClickHouse reachability,
- Redis reachability,
- MinIO readiness,
- Flink UI availability.

Acceptance criteria:
- one command gives quick confidence that the local platform is healthy.

## Configuration Defaults
Recommended first-pass defaults:
- input topic: `ad-clicks-v1`
- ClickHouse database: `stream_ads`
- MinIO bucket: `raw-events`
- Redis database: `0`

## Risks
- incorrect advertised listeners causing host-to-container connectivity issues,
- overcomplicated Compose setup before the first app code exists,
- incompatible image versions between Flink connectors and local runtime,
- accidental dependence on container-only networking from host-run services.

## Definition of Done
Milestone 1 is complete when:
- all infra services start locally and stay healthy,
- topic creation works,
- ClickHouse and Redis are reachable from the host,
- MinIO is ready for bucket-based archival,
- Flink UI is reachable and ready for later job submission,
- the bootstrap README and health-check scripts are committed.

## Suggested Build Order
1. Redpanda
2. ClickHouse
3. Redis
4. MinIO
5. Flink
6. health-check scripts
7. README polish

## Recommended Next Step
The next implementation step should be **Milestone 1.4: Developer bootstrap documentation**.

That gives us:
- a polished operator-style runbook for setup and recovery,
- a cleaner onboarding path for future readers,
- article-quality setup guidance that matches the working scripts.

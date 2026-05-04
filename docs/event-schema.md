# Event Schema

## Purpose
This document defines the initial event contract for the streaming system. It is intentionally small enough for Milestone 0, but structured to support versioning, validation, replay, and future extensions.

## Event Name
`ad_click.v1`

## Canonical JSON Shape
```json
{
  "schema_version": 1,
  "click_id": "1d91a2d4-6d3d-4f5a-86cb-77dce0a41234",
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

## Field Definitions
| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `schema_version` | integer | yes | Starts at `1` for this project. |
| `click_id` | string | yes | Unique event identifier used for dedupe. |
| `event_time` | integer | yes | Unix epoch seconds for event-time processing. |
| `ingest_time` | integer | yes | Unix epoch seconds when the producer emitted the event. |
| `user_id` | string | yes | Synthetic user identifier. |
| `ad_id` | string | yes | Ad identifier for fine-grained aggregation. |
| `campaign_id` | string | yes | Campaign identifier and default partitioning key. |
| `publisher_id` | string | yes | Publisher or inventory source identifier. |
| `country` | string | yes | ISO-style country code such as `US`. |
| `device_type` | string | yes | Initial allowed values: `mobile`, `desktop`, `tablet`, `tv`. |
| `cost_micros` | integer | yes | Cost in micros for simple spend aggregation. |

## Validation Rules
- `schema_version` must equal `1` for v1 consumers.
- `click_id` must be non-empty.
- `event_time` must be less than or equal to `ingest_time + allowed_clock_skew`.
- `event_time` must be within a sane replayable range for local tests.
- `campaign_id`, `ad_id`, and `publisher_id` must be non-empty.
- `country` must be a 2-character uppercase code in v1 synthetic data.
- `device_type` must be one of the allowed enum values.
- `cost_micros` must be greater than or equal to `0`.

## Time Semantics
### Event time
`event_time` is the source of truth for windowing and Top-K ranking windows.

### Ingest time
`ingest_time` is used for:
- measuring end-to-end freshness,
- debugging producer delay,
- simulating late events.

## Key Semantics
### Deduplication key
`click_id`

This must remain stable across retries and replay.

### Partitioning key
Default initial partition key:
- `campaign_id`

This is a deliberate choice for Milestone 0 because it makes skew visible and aligns with the first aggregate use case.

## Versioning Strategy
Rules:
- additive changes are preferred,
- required field removals are not allowed in place,
- breaking changes should move to `schema_version = 2`,
- replay jobs should be schema-aware.

Examples of additive v1-compatible changes:
- add `browser_family`,
- add `region`,
- add `is_duplicate_hint`.

Examples of breaking changes:
- changing `event_time` units,
- renaming `campaign_id`,
- changing `cost_micros` to floating-point dollars.

## Example Variants For Testing
### Normal event
```json
{
  "schema_version": 1,
  "click_id": "c1",
  "event_time": 1714580000,
  "ingest_time": 1714580001,
  "user_id": "u1",
  "ad_id": "ad-9",
  "campaign_id": "camp-2",
  "publisher_id": "pub-7",
  "country": "US",
  "device_type": "mobile",
  "cost_micros": 500
}
```

### Duplicate event
Same payload and same `click_id`, emitted again later.

### Late event
An event whose `event_time` falls behind the current watermark but still within allowed lateness.

### Very late event
An event that arrives after the allowed lateness budget and is counted separately or routed aside.

## Open Questions For Later Milestones
- Should event timestamps move from seconds to milliseconds?
- Do we want a separate `trace_id` for debugging producer and pipeline hops?
- Should synthetic data include an `ad_slot_id` or `placement_id` dimension?

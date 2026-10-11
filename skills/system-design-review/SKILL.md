---
name: system-design-review
description: Evaluate backend system designs for scalability, reliability, availability, consistency, security, cost, and operational tradeoffs. Use for architecture reviews, design documents, and system design interview practice.
---

# System Design Review

Review an existing or proposed architecture against explicit requirements. Highlight tradeoffs rather than prescribing technologies by fashion.

## Procedure
1. Establish functional requirements, actors, APIs/events, SLOs/SLAs, throughput, data volume, growth, latency targets, retention, consistency, regions, and budget. If unknown, use clearly labeled assumptions or questions.
2. Identify components and trust boundaries, data flow, synchronous/asynchronous dependencies, critical path, and state ownership. Prefer a Mermaid architecture diagram.
3. Estimate capacity with visible assumptions and units: QPS, storage, bandwidth, concurrency, partition counts, and hot-key risk. Do not fabricate production measurements.
4. Examine failure modes: dependency outages, retries, timeouts, backpressure, queues, poison messages, duplicate delivery, idempotency, circuit breaking, rate limits, partial failure, degraded mode, and disaster recovery.
5. Examine correctness and consistency: transaction scope, data ownership, ordering, consistency model, cache invalidation, pagination, schema evolution, and recovery/reconciliation.
6. Examine security and privacy: authentication, authorization, tenant isolation, secrets, encryption, audit logging, data retention, and abuse controls.
7. Examine operations: telemetry, alerting, rollout/rollback, canaries, schema migrations, testing, incident response, and cost control.
8. Present alternatives and the conditions under which each would be preferable. Rank problems by impact and likelihood; provide practical incremental mitigations.

## Output
Requirements and assumptions; architecture diagram; capacity sketch; top risks with P0-P3 severity and failure scenarios; alternatives/tradeoff matrix; recommended roadmap; unanswered questions. Note where benchmarks or load tests are needed.

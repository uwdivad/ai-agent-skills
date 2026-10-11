---
name: ai-pipeline-review
description: Audit LLM, retrieval augmented generation, agent, and AI document processing pipelines for correctness, retrieval quality, evaluation gaps, observability, security, cost, and resilience. Use for RAG and AI production-readiness reviews.
---

# AI Pipeline Review

Audit the complete AI pipeline from inputs and retrieval through model/tool calls, output validation, human review, and monitoring. Do not mistake prompts for enforcement boundaries.

## Procedure
1. Identify business task, desired behavior, quality thresholds, data sources, models/providers, embeddings, vector stores, orchestrators, tools, datasets, and evaluation infrastructure. Establish versions where possible.
2. Trace ingest: permissions, parsing, OCR, deduplication, chunking, document/version identity, metadata, lineage, retries, incremental updates, indexing failures, and deletion propagation.
3. Trace retrieval: query rewriting, filters, tenant isolation, embedding mismatch, stale indexes, hybrid search, reranking, top-k context budgets, and evidence provenance. Separate retrieval misses from generation errors.
4. Trace generation and agents: prompt injection via retrieved data/tool responses, excessive tool privileges, schema-validation gaps, hallucinated citations, unbounded loops, side effects, idempotency, timeouts, budget exhaustion, and model/provider fallback.
5. Trace security and privacy: credentials, access control before retrieval and tool actions, cross-tenant leakage, PII handling, unsafe log retention, human approval for consequential operations.
6. Trace resilience and cost: request tracing across stages, rate limits, retry jitter, dead letters, caching boundaries, circuit breakers, concurrency limits, token/cost attribution, and quality regressions.
7. Review evaluation methodology: representative labeled examples, gold-source correctness, retrieval recall/precision, faithfulness/groundedness, task success, calibrated human review, adversarial/permission cases, baseline comparisons, and dataset leakage. Do not equate LLM-judge scores with objective truth.
8. Output verified findings with severity P0-P3, exact file:line or config reference, failure mechanism, user impact, fix, and verification/eval case. Label missing evidence and suggested experiments separately.

## Output
Pipeline map with Mermaid diagram; stage-by-stage risks; prioritized findings; evaluation coverage matrix; observability gaps; practical remediation plan. Do not claim quality or cost metrics without measurements.

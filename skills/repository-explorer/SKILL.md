---
name: repository-explorer
description: Explore an unfamiliar code repository by tracing architecture, execution flows, framework choices, dependencies, and git history. Use for onboarding, system comprehension, and interview preparation.
---

# Repository Explorer

Build an evidence-backed mental model of a repository; never invent implementations or historical motivation.

## Procedure
1. Identify repository root, languages, packages, lockfiles, scripts, framework versions, entry points, test instructions, and deployment configuration. Respect excluded/generated directories.
2. Summarize major subsystems, ownership boundaries, storage, queues, external APIs, and request/job entry points.
3. For each important workflow, trace function-by-function from trigger to side effects. Cite symbol names, filenames and line numbers. Differentiate runtime dispatch from static calls.
4. Produce a concise Mermaid component diagram and at least one sequence diagram for a representative workflow. Mark inferred edges explicitly.
5. Map data contracts, persistence, caching, concurrency, transaction boundaries, retry/error behavior, configuration, observability, security boundaries, and testing strategy.
6. Read `git log --oneline`, blame, and relevant diffs if repository history is available. Explain *documented* changes and plausible tradeoffs; label inferred motivations as hypotheses. Never claim to know a developer's intent from code alone.
7. Describe how to run locally, exercise key paths, and safely debug. If commands are not run, mark them unverified.
8. Conclude with architecture risks, prioritized questions for maintainers, and an interview-ready narrative covering problem, constraints, tradeoffs, decisions, outcomes, and what remains unknown.

## Output sections
- Repository at a glance (facts and evidence)
- Components and dependencies
- Main workflows with call chains and Mermaid diagrams
- Data and operational model
- Git evolution (facts vs hypotheses)
- Setup and tests (verified vs unverified)
- Risks / unknowns
- Interview explanation (60-second and 3-minute variants)

Never paste credentials, raw secrets, or proprietary data into reports.

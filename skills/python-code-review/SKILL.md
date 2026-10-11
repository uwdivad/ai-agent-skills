---
name: python-code-review
description: Review Python code for correctness, maintainability, typing, concurrency, security, and performance problems. Use for Python pull requests, repository audits, and targeted bug investigations.
---

# Python Code Review

Review actual code and execution paths, not style preferences. Read-only unless the user explicitly requests changes.

## Procedure
1. Determine Python runtime, dependency manager, test framework, lint/typecheck tools, and boundaries of the request.
2. Map entry points, callers/callees, data transformations, exception paths, and external I/O. Inspect relevant tests.
3. Examine correctness first: mutable defaults, shared state, iteration mutation, aliasing, unreachable branches, boundary cases, error handling, unvalidated inputs, race conditions, timezone errors, serialization surprises, and exception suppression.
4. Examine performance using grounded evidence: N+1 queries, repeated deserialization, excessive allocations, accidental quadratic loops, inefficient synchronous I/O, missing pagination, and resource leaks.
5. Examine security: injection, unsafe deserialization, subprocess shell usage, path traversal, leaked credentials and PII, inadequate authorization, and dangerous logging.
6. Examine maintainability: unclear contracts, inappropriate abstraction, tightly coupled side effects, missing coverage, and risky interfaces. Avoid subjective nitpicks.
7. If tools are available, run narrowly relevant tests, ruff, mypy/pyright, or project commands; never assume a check succeeded without execution. Do not add dependencies without permission.
8. Report only reproducible or well-supported findings; include precise path:line, severity P0-P3, impact, evidence, recommended fix, and a targeted regression test. Separate conjectures from confirmed defects.

## Review constraints
- Be mindful of version-specific language behavior and framework APIs.
- Do not flag a pattern solely because a linter might disapprove.
- If reviewing a diff, prioritize introduced regressions and state scope limits.
- For an empty result say 'No confirmed findings within reviewed scope' and explain what was not tested.

## Output
Order by severity, each with **Finding**, **Evidence (file:line)**, **Failure scenario**, **Fix**, **Test**, and **Confidence**. Follow with assumptions and test coverage gaps.

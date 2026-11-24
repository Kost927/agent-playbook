---
name: review-task
description: Independently review a change against its original request, canonical specification, acceptance criteria, contracts, capability workstreams, and repository conventions. Use for fresh-context code review, acceptance review, or pre-ship verification; do not modify code on the first pass unless explicitly asked.
---

# Review Task

Review from primary artifacts rather than the implementer's confidence or summary.

## Load review evidence

1. Read applicable repository instructions. Work in a fresh context and record the reviewer and implementer tool/model, per *Context and models* in `docs/agent/workflow.md`.
2. Read `docs/agent/workflow.md`, `docs/agent/project-map.md`, `docs/agent/capability-map.md`, and `docs/agent/integrations.md` when present.
3. Locate the original request, canonical specification, acceptance criteria, contracts/ADRs, task state, complete diff, and relevant surrounding code.
4. If primary requirements are unavailable, state the limitation and do not infer intended behavior solely from the implementation.

## Review

- Confirm affected units, downstream consumers, active capability workstreams, and review scope.
- Build an acceptance-criteria coverage table before style commentary.
- For a task split into phases on one branch and pull request, the final review before merge covers the whole branch diff from its base and every phase's criteria, not only the last phase.
- For every criterion, locate implementation evidence and an observable test or other verification.
- Inspect established repository examples and behavior outside the diff where relevant.
- Check failures, recovery, compatibility, state, concurrency, security, delivery, and interaction behavior required by the active workstreams.
- When the task has `acceptance.md`, confirm the Plan section was committed before implementation and is unchanged since the latest acceptance plan commit, then read its Results: a `fail` is blocking, and a `not run` is blocking unless the owner's acceptance is recorded (`Owner accepted not run`, or in the pull request).
- When the repository has a test runner, detect removed, skipped, weakened, tautological, or implementation-mirroring tests. Run the playbook's `scripts/check-tests-diff.sh --repo <target> --tests-commit <sha> <base>` (tests commit from the task card) from a read-only clone of the playbook at the pinned revision, fetched as `docs/agent/workflow.md` describes; if it cannot be fetched, ask the human before recording `not run` (in a run with no human to ask, record it and flag it). Explain every reported item under Test integrity. The script cannot see an assertion weakened in place, so also read the test diff from the tests commit to the head.
- Run proportionate verified checks when available, including security commands from the project map, and record exact results. On Full routes run them from a clean checkout.
- Give every material finding a concrete trigger, expected and actual behavior, impact, precise location, and related criterion or invariant.
- Separate blocking findings, non-blocking improvements, unverified scenarios, and residual risk.

Keep the first pass diagnostic. Do not modify code unless the user explicitly asks for fixes after reviewing the findings.

## Output

Use the repository's canonical review artifact when an integration owns it; otherwise follow `templates/review-report.md` or its initialized local equivalent. Lead with findings ordered by severity, then acceptance coverage, checks performed, checks not performed, and residual risks. Say explicitly when no material findings are found without claiming unrun scenarios were verified.

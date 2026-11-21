# Agent Workflow

<!-- agent-playbook:start -->
Playbook source: `https://github.com/Kost927/agent-playbook`  
Playbook revision: `d182d60973bc7c796146478090d916ed088162c6`  
Last reconciled: `2026-11-21`  
Update the date only when this file's facts change; the revision always tracks the pinned playbook.

A reference such as "the playbook's `templates/pr-body.md`" means that path in the Playbook source at the Playbook revision above. Read it there, for example from a read-only clone or worktree at that revision; do not copy it into this repository unless asked. If it cannot be reached, record "not run — playbook unavailable" and ask the human.

## Required reading

1. Read repository and directory-specific instruction files.
2. Read [`project-map.md`](project-map.md) for verified commands, architecture, and examples.
3. Read [`capability-map.md`](capability-map.md) and activate every workstream affected by the task.
4. If `integrations.md` exists beside this file, use its primary workflow owner and canonical artifact mapping; do not run overlapping methodologies.

## Task process

1. Inspect the request and relevant code before editing.
2. Identify affected repository boundaries and capability workstreams, then select the Direct, Fast, Standard, or Full route based on risk and reversibility.
3. For Standard and Full routes, record the original request and acceptance criteria with stable IDs under `docs/agent/tasks/` (an active integration may override this path).
4. Ask questions and run checkpoints as described in [Questions and checkpoints](#questions-and-checkpoints) below; on Standard/Full, wait for approval before writing tests or implementation code.
5. Derive tests from acceptance criteria. Do not delete, skip, or weaken agreed tests. On Standard/Full, commit the tests (plus minimal stubs, no behavior) before implementation and record `Tests commit: <sha>` in the task card; the implementer escalates a wrong test instead of editing it, and a fix lands in a new tests-only commit added to that list. Before review, run the playbook's `scripts/check-tests-diff.sh --repo <target> --tests-commit <latest sha> <base>`; it is a heuristic, so the reviewer also reads the test diff and explains every reported item. With no test runner (test command `none configured`), propose adding one as a separate decision at the checkpoint; until then the Plan section of the task's `acceptance.md` (the playbook's `templates/acceptance.md`) is committed first instead of tests, recorded as `Acceptance plan commit: <sha>`, and the acceptance tester runs it before review.
6. Implement a scoped change using repository conventions and verified commands.
7. Report commands actually run, results, unrun checks, assumptions, and remaining risks.
8. For meaningful changes, use a fresh-context reviewer with the original request, acceptance criteria, contracts, diff, and repository access. On Full the reviewer runs checks from a clean checkout (fresh clone or worktree, clean install); on Standard it is recommended.
9. Open pull requests with the playbook's `templates/pr-body.md` (on Direct/Fast, Test integrity and Security checks may be `n/a — Direct/Fast`). For Standard/Full: re-run checks including the project map's security commands, exercise criteria in staging or preview when one exists, run DAST only for Full with a web surface and staging, update the changelog only if the repository keeps one, and never install scanners as part of a task. If a Full-route change has no security commands to run, record the gap as a risk and propose adding them as a separate decision.

## Route policy

- **Direct:** mechanical and behavior-preserving.
- **Fast:** small, familiar behavior with limited blast radius.
- **Standard:** user-visible or multi-module behavior and meaningful regression risk.
- **Full:** contracts, authorization, payments, migrations, sensitive data, difficult rollback, or high operational risk.

Size gives a starting default: one task in one unit with no behavior change → Direct, or a small familiar change → Fast; 2–5 tasks, several units, one new module or API, or a compatible internal contract change → Standard; more than 5 tasks, several teams, several new modules, or a public or breaking contract → Full. Risk always overrides size: authorization, payments, sensitive data, or difficult rollback → Full. Any migration → at least Standard; one that changes existing production data → Full. A task that changes a path listed under Risk zones in [`capability-map.md`](capability-map.md) starts at that zone's minimum route; a heavier route from other signals still wins. If size and risk disagree, take the heavier route. With uncertain size, take the lighter route and escalate on evidence; with uncertain risk, or both, take the heavier one.

A task should fit one focused implementation session and a reviewable diff (about 500 changed lines, excluding generated files and lockfiles); split larger ones or record why not. When review starts, a task has one implementation commit, after the tests commit on Standard/Full; refactoring and review fixes are follow-up commits for the same task or are squashed. When a task card exists, commit messages carry `Task: <id>` and `AC: <ids>` lines.

Design artifacts go in the task folder only when triggered, and are written before the checkpoint: the playbook's `templates/ux-flow.md` on Standard/Full when a human-facing interaction (screen or CLI) changes; the playbook's `templates/architecture.md` on Full, or on Standard when a new module or unit is added or boundaries change. Mutation testing runs on Full for critical domain logic (wrong money, data, or authorization outcomes) when the project map lists a tool; otherwise record the gap, propose adding one as a separate decision, and never install it as part of a task. Reuse the capability map's design system; never invent one.

Escalate the route when new evidence increases risk. Local repository requirements always apply.

## Questions and checkpoints

- Ask only when two reasonable implementations behave differently, a product/security/data-loss/irreversible decision is needed, the request conflicts with code, tests, or instructions, or the route rises mid-task.
- Do not ask what code, documentation, or the project map answers: look first, and ask only if they do not. Make process choices yourself and mention them.
- Lead with your recommendation, give concrete options with trade-offs, number questions, and ask dependent questions one at a time.
- **Direct/Fast:** proceed and list assumptions in the final report.
- **Standard/Full checkpoint:** after recording acceptance criteria and before writing tests or implementation code, send one message with route and reason, affected units and workstreams, acceptance criteria, assumptions, open questions with recommendations, and, when triggered, the UX flow and architecture summary; wait for approval. Approval covers only what was shown: if scope, acceptance criteria, or affected units change, send a new checkpoint.
- **Escalation mid-task:** if a Direct/Fast task needs Standard/Full, stop editing and send a checkpoint that lists the work already done before any further code.
- Record answers and decisions in the canonical specification, and unconfirmed assumptions in its Assumptions section.
- A Standard/Full checkpoint with no questions and no assumptions is a warning sign: re-read the request; if there truly are none, write "No open questions, because …". Do not invent questions to avoid it.
- **Standard/Full specifications** have goals and user stories; every user story has at least one criterion, each criterion names its story and type (`happy`, `error`, `edge`, `authorization`, `invariant`, `compatibility`), `happy` and `error` are required, and other types are covered or marked `n/a: <reason>`.

## Context and models

- Start each stage from artifacts on disk, not from conversation memory. Read only the files the task names; send long output to files. If you are building on an assumption the artifacts do not support, stop and return to the artifacts.
- **Standard/Full:** start a fresh session after the approved checkpoint and again before review. Before each reset, record the approval and decisions in the specification and write a handoff under `docs/agent/tasks/`; the next session starts from that handoff.
- Use subagents for context isolation with self-contained briefs: exploration returns conclusions, critique and devil's advocate see only artifacts, and the reviewer sees artifacts and the diff, never the implementer's narrative. On Standard/Full, tests come from a different context than the implementation.
- Review Standard/Full changes on a different model family than the implementation when available; otherwise another model or a fresh session. Record both in the review report.
- Use the model roster below for each role; never guess model names.

## Validation

Use only commands verified in the project map. Distinguish executed checks from conclusions based on code reading. Never claim a scenario was verified when it was not run.
<!-- agent-playbook:end -->

## Model roster

Owned by this repository; playbook updates keep it. Onboarding may add the `Independent review` row and fill roster rows that are missing, `unknown — asked, not answered`, or `session default` when the owner asks, only from the owner's answers; it never changes another recorded model. Use `session default` when no model is chosen; mark owner answers `(owner, <YYYY-MM-DD>)`.

| Role | Tier | Model |
| --- | --- | --- |
| Specification critique, architecture, review | deep | `session default` (owner, 2026-11-21) |
| Implementation, test authoring | standard | `session default` (owner, 2026-11-21) |
| Search, summaries, mechanical edits | fast | `session default` (owner, 2026-11-21) |
| Independent review | — | Codex, fresh session (owner, 2026-11-21) |

## Local additions

Content below this heading is maintained by the project team and must survive playbook updates.

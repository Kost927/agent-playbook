# Shared Task Workflow

Use this workflow after a target repository has been initialized. Local repository instructions and verified project facts override examples in this document.

## Choose a route

Select process depth from impact and reversibility. Size signals give a starting default; line count alone never decides.

| Route | Use when | Required artifacts and checks |
| --- | --- | --- |
| Direct | Mechanical, local, behavior-preserving change with cheap rollback | Clear request, focused diff review, proportionate existing check |
| Fast | Small, familiar behavior using an established pattern; limited blast radius | Short acceptance statement, implementation, focused test/check, self-review |
| Standard | User-visible behavior, multiple modules, new state/data flow, or meaningful regression risk | Specification with acceptance criteria, task plan, tests derived from criteria, implementation, independent review |
| Full | Public contract, authorization, payments, migration, sensitive data, cross-team dependency, difficult rollback, or high operational risk | Standard route plus UX/architecture/contract review as relevant, ADRs, compatibility and rollout plan, clean-environment validation, post-release monitoring |

Size signals suggest a default route:

| Signal | Direct | Fast | Standard | Full |
| --- | --- | --- | --- | --- |
| Behavior change | none | small and familiar | user-visible or multi-module | contract-level or cross-team |
| Expected tasks or PRs | 1 | 1 | 2–5 | more than 5, or several teams |
| New module or API | none | none | one | several, or a new subsystem |
| Contract change | none | none | internal, compatible | public or breaking |
| Affected units | one | one | several | several with deployment ordering |

Risk always overrides size: authorization, payments, sensitive data, or difficult rollback mean Full even for a small diff. Any migration means at least Standard; a migration that changes existing production data (backfill, rename, drop, a new required column) means Full. A task that changes a path listed under Risk zones in the capability map starts at that zone's minimum route; a heavier route from other signals still wins. When size and risk suggest different routes, take the heavier one. When the route is unclear, decide by what is uncertain: with uncertain size, take the lighter route and escalate when evidence appears; with uncertain risk (data, security, contracts), or when both are uncertain, take the heavier one.

Escalate the route whenever new evidence increases risk. An agent may recommend a route, but a human owns product and risk decisions.

## Questions and checkpoints

Ask questions that change what gets built, and nothing else. Every question costs the human attention; every wrong guess costs rework.

### When to ask

Stop and ask when:

- two reasonable implementations would behave observably differently;
- a product, security, data-loss, or irreversible decision is needed;
- the request conflicts with code, tests, or repository instructions;
- discovery raises the route mid-task (for example Fast becomes Standard).

### When not to ask

- The code, documentation, or project map can answer it: look first, and ask only if they do not.
- It is a process choice the agent owns, such as file names or test layout that follow existing conventions. Make the choice and mention it in the report.

### How to ask

- Lead with your recommendation, then give concrete options with their trade-offs.
- Number the questions so the human can answer briefly (for example "1a, 2 ok").
- Ask dependent questions one at a time; independent questions may go together in a checkpoint.
- Say what the answer changes when that is not obvious.

### Checkpoints by route

- **Direct and Fast:** proceed without stopping unless a "when to ask" condition applies, and list assumptions in the final report.
- **Standard and Full:** after specifying and critiquing the behavior (lifecycle steps 2–3) and before writing tests or implementation code, send one checkpoint message containing the route and why, affected units and workstreams, acceptance criteria, assumptions, open questions with recommendations, and, when triggered, the UX flow and an architecture summary (see step 4). Then wait for approval.
- Approval covers only what the checkpoint showed. If scope, acceptance criteria, or affected units change afterwards, send a new checkpoint before continuing.
- **Escalation mid-task:** when a Direct or Fast task turns out to need Standard or Full, stop editing, then send a checkpoint that also lists the work already done, before any further code.
- Record answers and decisions in the canonical specification (its Decisions table when using the playbook template), and unconfirmed assumptions in its Assumptions section.
- A Standard or Full checkpoint with no open questions and no assumptions is a warning sign: the request almost always leaves something unstated. Re-read it for unstated decisions; if there truly are none, write "No open questions, because …" with the reason. Do not invent questions to avoid writing this line.

## Context and models

Agent quality degrades as a conversation grows: old details crowd out new ones (context rot), a wrong assumption keeps steering later steps (context poisoning), and facts in the middle of a long context are missed (lost in the middle). Treat context as a resource to manage.

### Context hygiene

- Start every stage from artifacts on disk (request, specification, task card, handoff), not from what the conversation remembers.
- On Standard and Full routes, start a fresh session twice: after the checkpoint is approved, and after implementation before review. Before each reset, record the approval and any decisions in the specification and write a handoff under the task artifacts path; the next session (a new session or the tool's context-reset command) starts from that handoff.
- Read the files the task card names and the closest examples; do not load whole directories "for context".
- Send long command output to a file and read the part you need.
- If you notice you are building on an assumption the artifacts do not support, stop and return to the artifacts instead of patching the conversation.

### Subagents

Use subagents for context isolation first; parallelism is a side benefit.

- Exploration: a subagent searches and returns conclusions with paths, not file dumps.
- Specification critique and devil's advocate: a fresh subagent reads only the artifacts.
- Test authoring: on Standard and Full, tests come from a different context than the implementation (see lifecycle step 6).
- Review: the reviewer gets the original request, the specification, the diff, and repository access, never the implementer's narrative.

Give every subagent a self-contained brief with the paths it must read and the exact output you need.

### Model roles

| Tier | Use for |
| --- | --- |
| deep | specification critique, architecture and contract decisions, devil's advocate, review |
| standard | implementation, test authoring |
| fast | search, summaries, mechanical edits |

The target repository records which concrete model serves each tier in its local workflow. When none is recorded, use the session default and do not guess.

### Independent review across vendors

On Standard and Full routes, run the review on a different model family than the implementation when one is available, for example by implementing with one vendor's coding agent and reviewing with another's. Otherwise use another model or at least a fresh session. The review report states which tool and model implemented and which reviewed.

## Lifecycle

### 1. Discover

- Read the original request and applicable repository instructions.
- Inspect the project map, capability map, relevant code, configuration, tests, and good analogues.
- If `docs/agent/integrations.md` exists, follow its recorded primary workflow owner, artifact mapping, and conflict policy. Do not start a second methodology for the same task.
- Identify every affected unit and downstream consumer, then activate the relevant workstreams from [`profiles/capability-workstreams.md`](profiles/capability-workstreams.md).
- Separate verified facts, assumptions, and decisions that require human input.
- Ask questions according to [Questions and checkpoints](#questions-and-checkpoints).

### 2. Specify behavior

For standard and full routes, use the canonical specification artifact recorded by the active integration. When no integration owns specifications, create one from [`templates/specification.md`](templates/specification.md). State goals with observable success measures and the user stories they serve (`US-1: As a <role>, I want <capability>, so that <outcome>`). Give each acceptance criterion a stable ID such as `AC-1`, the story it serves, and a type, and express observable behavior, including failure, recovery, compatibility, and state transitions as relevant.

- Every user story has at least one criterion.
- Types are `happy`, `error`, `edge` (boundaries, empty states, limits), `authorization`, `invariant`, and `compatibility`. `happy` and `error` are required. The others are required when relevant; otherwise record `<type> — n/a: <reason>` instead of omitting them silently.
- Also consider recovery, accessibility, and operational behavior, and add criteria where they matter.
- Criteria describe behavior in the user's or consumer's terms. Naming the surface (API, CLI, a screen) is fine; paths, status codes, schemas, and queries belong in Contracts and invariants, and criteria reference them. This keeps criteria valid when the implementation changes.
- Avoid untestable wording such as "exactly as before" or "works correctly"; name what is observed.

Acceptance criteria are the shared contract between the test author, implementer, and reviewer. Preserve the original request alongside them.

### 3. Critique the specification

For material changes, use a fresh context to find contradictions and cases where two reasonable implementations would behave differently. The critique checks at least:

- every user story has a criterion, and every criterion names its story and type;
- the required types are present or recorded as `n/a` with a reason;
- no criterion contains implementation detail that belongs in Contracts and invariants;
- each criterion is specific enough that two teams would not build it differently.

Resolve important ambiguity before implementation. Record unresolved items explicitly. Write any design artifacts that step 4 triggers (UX flow, architecture) before this checkpoint, then run the Standard/Full checkpoint from [Questions and checkpoints](#questions-and-checkpoints).

### 4. Design only what risk and active workstreams require

- **Observable interaction:** invocation path, inputs, outcomes, alternatives, failures, recovery, and applicable usability or protocol constraints.
- **Architecture:** unit boundaries, data/control flow, dependency direction, failure handling, and costly-to-reverse decisions.
- **Contracts and state:** schemas, fields, types, optionality, errors, compatibility, concurrency, persistence, migrations, and ordering.
- **Operations and delivery:** build/publication/deployment scope, rollout, rollback, configuration, metrics, alerts, and baseline behavior.
- **Trust:** permissions, untrusted inputs, sensitive data, auditability, and compliance constraints.

Use an ADR based on [`templates/adr.md`](templates/adr.md) for important decisions with plausible alternatives. Do not create diagrams or documents that add no acceptance or maintenance value. These design artifacts are required only when their trigger applies, and live in the task folder next to the specification:

| Artifact | Required when |
| --- | --- |
| UX flow from [`templates/ux-flow.md`](templates/ux-flow.md) | Standard or Full route and a human-facing interaction changes; written before tests and shown at the checkpoint |
| Architecture from [`templates/architecture.md`](templates/architecture.md) (C4 context and containers in Mermaid, short arc42-style sections) | Full route, or Standard route that adds a new module or unit or changes boundaries between units; written before the checkpoint |
| Mutation testing | Full route with critical domain logic, and the project map lists a mutation-testing command; otherwise record the gap and propose adding a tool as a separate decision, and never install one as part of a task |

Critical domain logic means code whose silent mistake produces wrong money, data, or authorization outcomes. Record mutation results in the pull request.

When the capability map records a design system, use its existing components and tokens; a new component needs a justification in the specification's Decisions. When it records none, do not invent one.

### 5. Split into independently acceptable tasks

Use the canonical task artifact recorded by the active integration. When no integration owns task state, create task cards from [`templates/task.md`](templates/task.md). Each task should map to acceptance criteria, name its dependencies and relevant files, and have a verification method.

- A task should fit one focused implementation session (about a day of work) and a reviewable diff (about 500 changed lines, excluding generated files and lockfiles). These are guides, not gates: split larger tasks, or record in the task card's Size check why the task cannot be split.
- When review starts, a task has one implementation commit; on Standard and Full routes the tests commit comes before it. Refactoring after green and review fixes are follow-up commits for the same task, or are squashed before merge. A task escalated from Direct or Fast notes in its card the commits that predate its tests commit.
- When a task card exists, each commit message names the task and the criteria it covers on their own lines: `Task: <id>` and `AC: <ids>`.
- Prefer one observable behavior per task.

### 6. Derive tests from requirements

Choose the cheapest test level that proves observable behavior. On Standard and Full routes, tests come from a different context than the implementation: a separate subagent or session writes them from the acceptance criteria.

Before implementation, a new test should fail for the expected behavioral reason—not because of a broken import, invalid fixture, or environment failure. The implementer must not delete, skip, or weaken an agreed test. If a test conflicts with a requirement, stop and report the exact contradiction for separate review.

On Standard and Full routes, the test author commits the agreed tests before any implementation, and the task card records `Tests commit: <sha>`.

- The tests commit contains tests plus only the minimal stubs or interfaces needed for them to compile and fail for the expected behavioral reason; no behavior.
- The implementer does not change agreed test files afterwards. A wrong test is escalated: after the human or reviewer agrees, the test author fixes it in a new tests-only commit, and the task card lists every tests commit in order (`Tests commit: <sha1>, <sha2>`).
- New tests added after the tests commit are allowed; changes to agreed tests are not.
- When a Direct or Fast task escalates to Standard or Full mid-task, create the tests commit at that point and note in the task card which code predates it.

Before review, run `scripts/check-tests-diff.sh --repo <target> --tests-commit <latest sha> <base>` from the playbook checkout. It diffs from the merge base and reports deleted, renamed-away, or moved test files, removed test definitions, added skip or focus markers, fewer assertions, changed test configuration, and agreed tests changed after the tests commit. It is a heuristic with a known blind spot: an assertion weakened in place (for example `== 3` changed to `is not None`) is not detected. The reviewer therefore reads the test diff from the tests commit to the head and explains every reported item; a clean result is not proof.

### 7. Implement

Follow [`roles/implementer.md`](roles/implementer.md). Keep the diff scoped, follow project conventions, preserve compatibility unless explicitly changed, and run relevant checks. Separate results actually observed from conclusions inferred by reading code.

### 8. Hand off primary evidence

Use [`templates/handoff.md`](templates/handoff.md) whenever a fresh session continues the work, which on Standard and Full routes is always. The handoff should point to the original request, accepted specification, relevant files, completed work, open decisions, checks, and next action. Do not make the implementer's narrative the reviewer's only source of requirements.

### 9. Review independently

Start a fresh reviewer session (required on Standard and Full; see [Context and models](#context-and-models)) and follow [`roles/reviewer.md`](roles/reviewer.md). Provide the original request, specification/acceptance criteria, relevant contracts, diff, and repository access. For each acceptance criterion, find implementation and test evidence. Findings require a concrete counterexample, user impact, and location.

On Full routes the reviewer runs the checks from a clean checkout: a fresh clone or worktree with a clean dependency install, so "works on my machine" state cannot hide failures. On Standard routes a clean checkout is recommended.

### 10. Ship and observe

Prepare every pull request from [`templates/pr-body.md`](templates/pr-body.md); on Direct and Fast routes its Test integrity and Security checks sections may say `n/a — Direct/Fast`. For Standard and Full routes:

- Re-run the verified checks, including the project map's security commands (`Security: static analysis`, `Security: dependency audit`) when they exist. If a Full-route repository has none, record the gap as a risk and propose adding them as a separate human decision; never install scanners as part of a task.
- Run a dynamic scan (DAST) only on Full routes with a web surface and an existing staging or preview environment; otherwise record it as not run with the reason.
- When the repository has a staging or preview environment, exercise the acceptance criteria there, not only locally.
- Update the changelog only when the repository keeps a changelog, in its format; otherwise the release note stays in the pull request.
- Prepare release and rollback information, and monitor signals related to the change after deployment. Monitoring duration and thresholds come from the target service's operational context, not a universal number.

### 11. Retain useful knowledge

Keep specifications, contracts, important ADRs, and durable project-map improvements. Remove or archive temporary task mechanics according to repository policy. When a failure reveals a repeated discovery problem, update the project map, workflow, test suite, or CI so the next agent benefits.

## Evidence rules

- Cite file paths, commands, test names, or observable results.
- Say “not run” when a check was not run and explain why.
- Do not equate a green build with completion of every acceptance criterion.
- Do not claim production safety from local tests alone.
- Treat cross-repository and operational facts as unknown until verified.

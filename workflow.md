# Shared Task Workflow

Use this workflow after a target repository has been initialized. Local repository instructions and verified project facts override examples in this document.

## Choose a route

Select process depth from impact and reversibility, not line count.

| Route | Use when | Required artifacts and checks |
| --- | --- | --- |
| Direct | Mechanical, local, behavior-preserving change with cheap rollback | Clear request, focused diff review, proportionate existing check |
| Fast | Small, familiar behavior using an established pattern; limited blast radius | Short acceptance statement, implementation, focused test/check, self-review |
| Standard | User-visible behavior, multiple modules, new state/data flow, or meaningful regression risk | Specification with acceptance criteria, task plan, tests derived from criteria, implementation, independent review |
| Full | Public contract, authorization, payments, migration, sensitive data, cross-team dependency, difficult rollback, or high operational risk | Standard route plus UX/architecture/contract review as relevant, ADRs, compatibility and rollout plan, clean-environment validation, post-release monitoring |

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
- **Standard and Full:** after specifying and critiquing the behavior (lifecycle steps 2–3) and before writing tests or implementation code, send one checkpoint message containing the route and why, affected units and workstreams, acceptance criteria, assumptions, and open questions with recommendations. Then wait for approval.
- Approval covers only what the checkpoint showed. If scope, acceptance criteria, or affected units change afterwards, send a new checkpoint before continuing.
- **Escalation mid-task:** when a Direct or Fast task turns out to need Standard or Full, stop editing, then send a checkpoint that also lists the work already done, before any further code.
- Record answers and decisions in the canonical specification (its Decisions table when using the playbook template), and unconfirmed assumptions in its Assumptions section.

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

For standard and full routes, use the canonical specification artifact recorded by the active integration. When no integration owns specifications, create one from [`templates/specification.md`](templates/specification.md). Give each acceptance criterion a stable ID such as `AC-1` and express observable behavior, including failure, recovery, compatibility, and state transitions as relevant.

Acceptance criteria are the shared contract between the test author, implementer, and reviewer. Preserve the original request alongside them.

### 3. Critique the specification

For material changes, use a fresh context to find contradictions and cases where two reasonable implementations would behave differently. Resolve important ambiguity before implementation. Record unresolved items explicitly. Then run the Standard/Full checkpoint from [Questions and checkpoints](#questions-and-checkpoints).

### 4. Design only what risk and active workstreams require

- **Observable interaction:** invocation path, inputs, outcomes, alternatives, failures, recovery, and applicable usability or protocol constraints.
- **Architecture:** unit boundaries, data/control flow, dependency direction, failure handling, and costly-to-reverse decisions.
- **Contracts and state:** schemas, fields, types, optionality, errors, compatibility, concurrency, persistence, migrations, and ordering.
- **Operations and delivery:** build/publication/deployment scope, rollout, rollback, configuration, metrics, alerts, and baseline behavior.
- **Trust:** permissions, untrusted inputs, sensitive data, auditability, and compliance constraints.

Use an ADR based on [`templates/adr.md`](templates/adr.md) for important decisions with plausible alternatives. Do not create diagrams or documents that add no acceptance or maintenance value.

### 5. Split into independently acceptable tasks

Use the canonical task artifact recorded by the active integration. When no integration owns task state, create task cards from [`templates/task.md`](templates/task.md). Each task should map to acceptance criteria, name its dependencies and relevant files, and have a verification method. Prefer one observable behavior per commit where practical.

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

### 10. Ship and observe

Run required checks from a clean environment when risk warrants it. Exercise acceptance criteria in the running system, prepare release/rollback information, and monitor signals related to the change after deployment. Monitoring duration and thresholds must come from the target service's operational context, not a universal number.

### 11. Retain useful knowledge

Keep specifications, contracts, important ADRs, and durable project-map improvements. Remove or archive temporary task mechanics according to repository policy. When a failure reveals a repeated discovery problem, update the project map, workflow, test suite, or CI so the next agent benefits.

## Evidence rules

- Cite file paths, commands, test names, or observable results.
- Say “not run” when a check was not run and explain why.
- Do not equate a green build with completion of every acceptance criterion.
- Do not claim production safety from local tests alone.
- Treat cross-repository and operational facts as unknown until verified.

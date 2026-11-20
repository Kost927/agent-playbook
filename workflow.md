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

## Lifecycle

### 1. Discover

- Read the original request and applicable repository instructions.
- Inspect the project map, capability map, relevant code, configuration, tests, and good analogues.
- If `docs/agent/integrations.md` exists, follow its recorded primary workflow owner, artifact mapping, and conflict policy. Do not start a second methodology for the same task.
- Identify every affected unit and downstream consumer, then activate the relevant workstreams from [`profiles/capability-workstreams.md`](profiles/capability-workstreams.md).
- Separate verified facts, assumptions, and decisions that require human input.
- Ask only questions whose answers change observable behavior, scope, safety, or architecture.

### 2. Specify behavior

For standard and full routes, use the canonical specification artifact recorded by the active integration. When no integration owns specifications, create one from [`templates/specification.md`](templates/specification.md). Give each acceptance criterion a stable ID such as `AC-1` and express observable behavior, including failure, recovery, compatibility, and state transitions as relevant.

Acceptance criteria are the shared contract between the test author, implementer, and reviewer. Preserve the original request alongside them.

### 3. Critique the specification

For material changes, use a fresh context to find contradictions and cases where two reasonable implementations would behave differently. Resolve important ambiguity before implementation. Record unresolved items explicitly.

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

Choose the cheapest test level that proves observable behavior. For high-risk behavior, separate the test-author context from the implementer context.

Before implementation, a new test should fail for the expected behavioral reason—not because of a broken import, invalid fixture, or environment failure. The implementer must not delete, skip, or weaken an agreed test. If a test conflicts with a requirement, stop and report the exact contradiction for separate review.

### 7. Implement

Follow [`roles/implementer.md`](roles/implementer.md). Keep the diff scoped, follow project conventions, preserve compatibility unless explicitly changed, and run relevant checks. Separate results actually observed from conclusions inferred by reading code.

### 8. Hand off primary evidence

Use [`templates/handoff.md`](templates/handoff.md) when another session continues the work. The handoff should point to the original request, accepted specification, relevant files, completed work, open decisions, checks, and next action. Do not make the implementer's narrative the reviewer's only source of requirements.

### 9. Review independently

Start a fresh reviewer session when practical and follow [`roles/reviewer.md`](roles/reviewer.md). Provide the original request, specification/acceptance criteria, relevant contracts, diff, and repository access. For each acceptance criterion, find implementation and test evidence. Findings require a concrete counterexample, user impact, and location.

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

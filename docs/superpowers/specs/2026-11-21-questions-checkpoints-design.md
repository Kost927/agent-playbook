# Questions and Checkpoints — Design

Date: 2026-11-21
Status: approved

## Intent

Agents should ask the right questions during everyday tasks, not only during greenfield setup. Today `workflow.md` has a single rule ("Ask only questions whose answers change observable behavior, scope, safety, or architecture") and does not say when to stop, how to ask, or whether to wait for approval before implementing.

## Goals

- One canonical section in `workflow.md` defining when to ask, when not to ask, question format, and route-based checkpoints.
- Direct/Fast: proceed without stopping unless blocked; list assumptions in the final report.
- Standard/Full: one checkpoint message before code; wait for human approval.
- Answers are durable: recorded in the specification.

## Non-goals

- Changes to `docs/flow.html` and `roles/reviewer.md`.
- Tool-specific question UIs.

## Anti-goals

- Asking what the code, docs, or project map already answer.
- A stream of small questions on Direct/Fast tasks.
- Treating approval as covering scope that was not shown.

## Approaches considered

| Option | Trade-off | Decision |
| --- | --- | --- |
| A. Ask only when blocked | Fastest; risk of building the wrong thing | Rejected |
| B. Checkpoint by route | Process depth tracks risk, like the rest of the playbook | **Chosen** |
| C. Confirm a plan before every change | Most control; irritating on trivial tasks | Rejected |

## Design

### `workflow.md` — new section "Questions and checkpoints"

Stop and ask when:

- two reasonable implementations would behave observably differently;
- a product, security, data-loss, or irreversible decision is needed;
- the request conflicts with code, tests, or repository instructions;
- discovery raises the route mid-task.

Do not ask when:

- code, documentation, or the project map can answer it — look first;
- it is a process choice the agent owns (file names, test layout following conventions).

Format: lead with the recommendation, then concrete options with trade-offs; number questions so the human can answer briefly ("1a, 2 ok"); ask dependent questions one at a time.

Direct/Fast: proceed; list assumptions in the final report. If risk rises, escalate the route and run a checkpoint.

Standard/Full checkpoint: before code, one message with route and reason, affected workstreams, acceptance criteria, assumptions, and open questions with recommendations; wait for approval. Approval covers only what was shown; a scope change requires a new checkpoint.

Answers are recorded in the specification's Decisions table.

### References

Target repositories receive only `docs/agent/workflow.md` (from `templates/local-workflow.md`), not the playbook's `workflow.md`. The local template therefore carries a condensed, playbook-managed copy of the rules; `validate.sh` checks that key phrases stay in both.


- `templates/local-workflow.md`, `skills/execute-task-workflow/SKILL.md`, `roles/implementer.md` point to the section and state the checkpoint in one line.
- `workflow.md` Discover step replaces its single question rule with a link to the section.

### Templates

- `templates/specification.md`: add an `## Assumptions` section.

### Validation

- `scripts/validate.sh` checks that `workflow.md` contains the section heading and the checkpoint rule, and that the referencing files mention it.

## Left to the builder

- Exact wording and order within the section.
- Exact phrases the validator matches.

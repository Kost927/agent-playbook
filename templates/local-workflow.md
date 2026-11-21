# Agent Workflow

<!-- agent-playbook:start -->
Playbook source: `<PLAYBOOK_URL>`  
Playbook revision: `<TAG_OR_COMMIT_SHA>`  
Last reconciled: `<YYYY-MM-DD>`  
Update the date only when this file's facts change; the revision always tracks the pinned playbook.

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
5. Derive tests from acceptance criteria. Do not delete, skip, or weaken agreed tests.
6. Implement a scoped change using repository conventions and verified commands.
7. Report commands actually run, results, unrun checks, assumptions, and remaining risks.
8. For meaningful changes, use a fresh-context reviewer with the original request, acceptance criteria, contracts, diff, and repository access.

## Route policy

- **Direct:** mechanical and behavior-preserving.
- **Fast:** small, familiar behavior with limited blast radius.
- **Standard:** user-visible or multi-module behavior and meaningful regression risk.
- **Full:** contracts, authorization, payments, migrations, sensitive data, difficult rollback, or high operational risk.

Escalate the route when new evidence increases risk. Local repository requirements always apply.

## Questions and checkpoints

- Ask only when two reasonable implementations behave differently, a product/security/data-loss/irreversible decision is needed, the request conflicts with code, tests, or instructions, or the route rises mid-task.
- Do not ask what code, documentation, or the project map answers: look first, and ask only if they do not. Make process choices yourself and mention them.
- Lead with your recommendation, give concrete options with trade-offs, number questions, and ask dependent questions one at a time.
- **Direct/Fast:** proceed and list assumptions in the final report.
- **Standard/Full checkpoint:** after recording acceptance criteria and before writing tests or implementation code, send one message with route and reason, affected units and workstreams, acceptance criteria, assumptions, and open questions with recommendations; wait for approval. Approval covers only what was shown: if scope, acceptance criteria, or affected units change, send a new checkpoint.
- **Escalation mid-task:** if a Direct/Fast task needs Standard/Full, stop editing and send a checkpoint that lists the work already done before any further code.
- Record answers and decisions in the canonical specification, and unconfirmed assumptions in its Assumptions section.

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

Owned by this repository; playbook updates keep it. Use `session default` when no model is chosen.

| Role | Tier | Model |
| --- | --- | --- |
| Specification critique, architecture, review | deep | `<model or session default>` |
| Implementation, test authoring | standard | `<model or session default>` |
| Search, summaries, mechanical edits | fast | `<model or session default>` |

## Local additions

Content below this heading is maintained by the project team and must survive playbook updates.

# Agent Workflow

<!-- agent-playbook:start -->
Playbook source: `<PLAYBOOK_URL>`  
Playbook revision: `<TAG_OR_COMMIT_SHA>`  
Last reconciled: `<YYYY-MM-DD>`

## Required reading

1. Read repository and directory-specific instruction files.
2. Read [`project-map.md`](project-map.md) for verified commands, architecture, and examples.
3. Read [`capability-map.md`](capability-map.md) and activate every workstream affected by the task.
4. If `integrations.md` exists beside this file, use its primary workflow owner and canonical artifact mapping; do not run overlapping methodologies.

## Task process

1. Inspect the request and relevant code before editing.
2. Identify affected repository boundaries and capability workstreams, then select the Direct, Fast, Standard, or Full route based on risk and reversibility.
3. For Standard and Full routes, record the original request and acceptance criteria with stable IDs under `<TASK_ARTIFACTS_PATH>`.
4. Derive tests from acceptance criteria. Do not delete, skip, or weaken agreed tests.
5. Implement a scoped change using repository conventions and verified commands.
6. Report commands actually run, results, unrun checks, assumptions, and remaining risks.
7. For meaningful changes, use a fresh-context reviewer with the original request, acceptance criteria, contracts, diff, and repository access.

## Route policy

- **Direct:** mechanical and behavior-preserving.
- **Fast:** small, familiar behavior with limited blast radius.
- **Standard:** user-visible or multi-module behavior and meaningful regression risk.
- **Full:** contracts, authorization, payments, migrations, sensitive data, difficult rollback, or high operational risk.

Escalate the route when new evidence increases risk. Local repository requirements always apply.

## Validation

Use only commands verified in the project map. Distinguish executed checks from conclusions based on code reading. Never claim a scenario was verified when it was not run.
<!-- agent-playbook:end -->

## Local additions

Content below this heading is maintained by the project team and must survive playbook updates.

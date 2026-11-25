---
name: execute-task-workflow
description: Plan and implement a repository task using its initialized Agent Playbook workflow. Use for feature, fix, refactor, migration, infrastructure, documentation, or other implementation work that should follow local route selection, acceptance criteria, tests, and capability workstreams.
---

# Execute Task Workflow

Use the target repository's initialized workflow rather than a generic language- or framework-specific process.

## Load local context

1. Read applicable repository instruction files.
2. Read `docs/agent/workflow.md`, `docs/agent/project-map.md`, and `docs/agent/capability-map.md` when present.
3. Read `docs/agent/integrations.md` when present and respect its primary workflow owner and canonical artifact mapping.
4. If the repository is not initialized, stop task implementation and recommend `initialize-agent-workflow`; do not fabricate local maps.

## Perform the task

- Preserve the original request as primary evidence.
- Manage context and subagents per *Context and models* in `docs/agent/workflow.md`: start from artifacts on disk and, on Standard/Full, start a fresh session after the checkpoint and before review.
- Identify affected units, downstream consumers, and capability workstreams.
- Select Direct, Fast, Standard, or Full according to the local workflow and actual risk. Escalate when discovery increases risk.
- Use the canonical specification and task artifacts owned by the recorded integration. When none exists, use the repository's local playbook templates.
- Ask questions per *Questions and checkpoints* in `docs/agent/workflow.md`; on Standard/Full, send one checkpoint summary, ask its open questions one at a time ending with the approval question, and wait for approval before code.
- Follow *Safety on every route* in `docs/agent/workflow.md` on every route: no push, merge, deploying tag, force-push, or auto-merge into what deploys without explicit approval for that specific action after review (a general "do it" does not count); never ask for secrets in the chat.
- Derive verification from acceptance criteria. Do not delete, skip, loosen, or rewrite agreed tests merely to obtain a pass.
- On Standard/Full, keep this order from *Task process* in `docs/agent/workflow.md`: (1) after approval, a different context writes the tests (none with no test runner) and, when a human-facing interaction changes or there is no test runner, the Plan of `acceptance.md`; their commits come before implementation and the task card records `Tests commit` and `Acceptance plan commit` (the plan commit carries `Acceptance plan hash` in its message when task artifacts are not committed); (2) implementation commit; (3) when a Plan exists, the acceptance tester runs it in a fresh context and fills Results; (4) the fresh-context review gets those Results, so acceptance runs before review, not after; (5) before a squash merge, propose the squash commit message in the pull request body. An acceptance criterion or check that cannot run is reported as `not run` with the reason and needs the owner's acceptance; the steps themselves are not skipped.
- Implement the smallest coherent change using verified repository commands and established examples.
- Distinguish executed checks from conclusions based on code reading.
- Prepare primary artifacts and evidence for a fresh independent review when the route requires it.

Do not install tools, change workflow ownership, or expand product scope as part of task execution unless the user separately requests it.

## Completion report

Report the selected route, affected workstreams, acceptance-criteria status, changed files, commands and results, checks not run, assumptions, residual risks, and the next workflow action.

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
- Identify affected units, downstream consumers, and capability workstreams.
- Select Direct, Fast, Standard, or Full according to the local workflow and actual risk. Escalate when discovery increases risk.
- Use the canonical specification and task artifacts owned by the recorded integration. When none exists, use the repository's local playbook templates.
- Ask questions per *Questions and checkpoints* in `docs/agent/workflow.md`; on Standard/Full, send one checkpoint message and wait for approval before code.
- Derive verification from acceptance criteria. Do not delete, skip, loosen, or rewrite agreed tests merely to obtain a pass.
- Implement the smallest coherent change using verified repository commands and established examples.
- Distinguish executed checks from conclusions based on code reading.
- Prepare primary artifacts and evidence for a fresh independent review when the route requires it.

Do not install tools, change workflow ownership, or expand product scope as part of task execution unless the user separately requests it.

## Completion report

Report the selected route, affected workstreams, acceptance-criteria status, changed files, commands and results, checks not run, assumptions, residual risks, and the next workflow action.

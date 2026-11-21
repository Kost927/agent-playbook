# Context and Models — Design

Date: 2026-11-21
Status: approved

## Intent

The source video (chapters 6:02–8:48) treats context management and model choice as core to agent quality: context rot, poisoning, and lost-in-the-middle; subagents as context isolation; review by a different model or vendor; matching models to roles. The playbook covers only fresh-context review and spec critique.

## Goals

- One canonical section "Context and models" in `workflow.md`, with a condensed managed copy in `templates/local-workflow.md`.
- Context hygiene: stages start from artifacts on disk; Standard/Full start a fresh session after the approved checkpoint and after implementation; read only files the task names; long output goes to files; on suspected poisoning return to artifacts.
- Subagents for isolation: exploration (conclusions back), spec critique, test authoring separate from implementation, review; briefs carry paths; reviewers never get the implementer's narrative.
- Three model tiers (deep, standard, fast) mapped to roles; the target repository records tier → model in `docs/agent/workflow.md`, default `session default`.
- Cross-vendor review on Standard/Full when available; otherwise another model or a fresh session; the report states which.
- `templates/review-report.md` records implementer and reviewer tool/model; `templates/handoff.md` gains a fresh-session reading list.

## Non-goals

- Naming specific models or versions in the playbook.
- Updating `docs/flow.html` (done once after all video-gap items).

## Approaches considered

| Option | Trade-off | Decision |
| --- | --- | --- |
| Tiers in the playbook, concrete models per repository | Durable; needs a filled table per repository | **Chosen** |
| Concrete model names in the playbook | Immediately usable; stale within months while the playbook is pinned by tag | Rejected |

## Design

- `workflow.md`: new `## Context and models` after "Questions and checkpoints", subsections `### Context hygiene`, `### Subagents`, `### Model roles`, `### Independent review across vendors`.
- `templates/local-workflow.md` managed block: condensed rules plus a model roster table (`Role | Tier | Model`) whose Model cells are placeholders filled at bootstrap, `session default` when unknown.
- `bootstrap.md` step 6: fill the roster from the user's request or leave `session default`; never guess.
- References: `roles/reviewer.md`, `roles/implementer.md`, `skills/review-task`, `skills/execute-task-workflow` point to the section in one line each.
- Examples: regenerate `docs/agent/workflow.md` in both examples from the updated template.
- `scripts/validate.sh`: phrase checks for each rule in both copies.

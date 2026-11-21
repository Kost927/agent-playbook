# Agent Playbook

A reusable, vendor-neutral playbook for setting up Claude Code, Codex, and Cursor in any repository, with project-specific instructions for discovery, planning, implementation, testing, handoffs, and independent code review.

[Open the interactive workflow map](https://kost927.github.io/agent-playbook/flow.html) (source: [`docs/flow.html`](docs/flow.html)) to explore how repository evidence, capability workstreams, task routes, and optional integrations fit together.

The playbook keeps shared process here and writes only repository-specific facts into the target project. It is language-, framework-, and architecture-neutral: the bootstrap discovers the repository's actual components and composes the necessary workstreams from evidence. It is designed for a workflow in which one agent implements a change and a fresh agent independently reviews it against the original requirements.

## Quick start

Open any target repository—service, application, library, infrastructure project, monorepo, or a mixture—in Claude Code, Codex, or Cursor and use this prompt. Name only the agents you use: the agent creates entry points and skill copies for each one named (for example, a Cursor-only repository gets no `CLAUDE.md`). The last line lets the agent include your user-level skills, plugins, and MCP servers in the AI setup audit; remove it and the agent asks once instead.

```text
Initialize the agent workflow for Claude Code, Codex, and Cursor in this
repository using https://github.com/Kost927/agent-playbook.

Read bootstrap.md first. Inspect this repository before changing files,
preserve existing instructions and manual additions, derive the relevant
capability workstreams from repository evidence, and show the final diff plus
validation results.

You may read my user-level AI setup (names and descriptions only) for the audit.
```

Before anything is written, the agent audits the existing AI setup ([`audit.md`](audit.md)): duplicate or diverged skills, competing skill triggers, contradictory instruction files, blocking hooks, MCP drift, and literal secrets, plus your user-level setup when you allow it. On first initialization the agent then sends one onboarding message that starts with the audit findings and then asks the questions the code cannot answer: which paths are risk zones (payments, authorization, sensitive data, difficult rollback), whether a staging environment exists, what performs independent review, and which models to use. It also recommends MCP servers and plugins tied to what it found in the repository. It waits for your answers, records them, and installs nothing without your explicit yes. See [`onboarding.md`](onboarding.md).

To see what a result looks like, open the initialized example in [`examples/task-tracker/`](examples/task-tracker/).

For reproducible setup, replace the default branch URL with a release tag or commit SHA. The initialized project records that revision in `docs/agent/workflow.md`.

## New projects

The same prompt works in an empty repository. When there is no code to discover, the agent switches to [`greenfield.md`](greenfield.md):

1. It interviews you one question at a time: what you are building and for whom, success, non-goals, constraints, and the first milestone.
2. It proposes 2–3 stack options with trade-offs and a recommendation; you choose.
3. It records `docs/agent/product-brief.md`, a stack ADR (`docs/adr/0001-stack.md` unless the repository already keeps ADRs elsewhere), maps with `planned` entries, and a scaffolding task card.
4. Scaffolding runs as the first regular task; a later update run marks planned facts as `verified`.

## What initialization creates

The exact output is adapted to the target repository. A simple repository may receive:

```text
AGENTS.md
CLAUDE.md
docs/agent/
├── workflow.md
├── project-map.md
└── capability-map.md
.agents/skills/<skill>/SKILL.md   # Codex and Cursor
.claude/skills/<skill>/SKILL.md   # Claude Code, identical copy
```

- `AGENTS.md` holds the short managed entry point; `CLAUDE.md` imports it with `@AGENTS.md`, because Claude Code reads `AGENTS.md` only when no `CLAUDE.md` exists. Cursor reads `AGENTS.md` and `.agents/skills/` directly and gets no files of its own; existing `.cursor/rules` are preserved.
- `docs/agent/workflow.md` contains the local task workflow and playbook revision.
- `docs/agent/project-map.md` records verified commands, architecture, conventions, and good in-repository examples.
- `docs/agent/capability-map.md` records the repository's detected capabilities, boundaries, and the checks that apply to each one.
- Task-specific specifications, task cards, ADRs, and review reports are created only when a task requires them.

In a monorepo, the root files describe shared policy and package discovery. More specific instruction files may be created at package or subsystem boundaries only when their commands or constraints differ. A task activates every affected workstream—for example interface, service contract, persistence, asynchronous processing, deployment, or published-library compatibility—regardless of the implementation language.

## How adaptation works

Bootstrap does not copy a predetermined stack workflow. It discovers units and activates concerns compositionally:

| Repository evidence | Resulting workstreams |
| --- | --- |
| A process exposes a versioned protocol and writes durable state | Contract compatibility, data/state, security, delivery, and observability |
| An application presents human interaction and consumes remote contracts | Interaction, accessibility/usability where applicable, consumer contracts, state, and delivery |
| A package is consumed by several internal or external units | Published-artifact compatibility, consumer validation, versioning, and release |
| A repository contains several independently built or deployed units | Root policy plus unit graph, scoped commands, affected-dependent validation, and any workstreams detected per unit |
| Infrastructure definitions change runtime permissions or topology | Infrastructure/delivery, security, rollback, drift, and operational validation |

These are examples of composition, not repository types. The same repository or task can activate all of them.

## Everyday use

Implementation prompt:

```text
Implement this task using the repository workflow. Start from the original
request, select the appropriate route, and record acceptance criteria before
implementation. Do not weaken agreed tests. Report the commands actually run
and any remaining risks.
```

Independent review prompt, ideally in a fresh Codex session:

```text
Independently review the current task using the repository workflow. Read the
original request, acceptance criteria, relevant contract, and diff. Map every
acceptance criterion to implementation and test evidence. Run relevant checks
and report findings before suggestions. Do not modify code in this pass.
```

## Repository contents

- [`bootstrap.md`](bootstrap.md) — safe initialization and update procedure.
- [`greenfield.md`](greenfield.md) — interview and stack-decision procedure for new, empty repositories.
- [`audit.md`](audit.md) — audit of existing AI setup (skills, instructions, hooks, MCP) before initialization.
- [`scripts/audit-ai-setup.sh`](scripts/audit-ai-setup.sh) — read-only audit script used by `audit.md`.
- [`onboarding.md`](onboarding.md) — first-initialization questions (risk zones, staging, review, models) and tool recommendations.
- [`workflow.md`](workflow.md) — route selection and the end-to-end task lifecycle.
- [`roles/implementer.md`](roles/implementer.md) — implementation contract.
- [`roles/reviewer.md`](roles/reviewer.md) — independent review contract.
- [`profiles/capability-workstreams.md`](profiles/capability-workstreams.md) — composable, technology-neutral discovery and validation dimensions.
- [`integrations.md`](integrations.md) — optional agent-methodology and SDD tool adapters, selection rules, and conflict policy.
- [`docs/flow.html`](docs/flow.html) — interactive workflow and capability-composition map.
- [`skills/`](skills/) — reusable initialization, task-execution, and independent-review skill templates.
- [`templates/`](templates/) — local workflow, entry points, project/capability maps, product brief, ADR, specification, UX flow, architecture, task, handoff, review, and pull-request templates.
- [`examples/task-tracker/`](examples/task-tracker/) — a small repository initialized by following `bootstrap.md`, with its onboarding answers.
- [`examples/greenfield-notes/`](examples/greenfield-notes/) — an empty repository after greenfield initialization, with the interview that produced it.
- [`scripts/check-target.sh`](scripts/check-target.sh) — read-only check of an initialized target repository.
- [`scripts/check-tests-diff.sh`](scripts/check-tests-diff.sh) — report deleted, skipped, or weakened tests in a change, for reviewers.
- [`scripts/validate.sh`](scripts/validate.sh) — repository structure, Markdown-link, rule-phrase, and example checks.

## Design principles

1. The target repository is the source of truth for commands and conventions.
2. Requirements and acceptance criteria are passed independently of an implementer's explanation.
3. Tests derive from requirements, not from completed implementation.
4. A fresh reviewer verifies observable behavior and supplies concrete evidence.
5. Process depth follows risk: small diffs are not automatically low risk.
6. Generated files are safe to update: manual content is preserved and repeated initialization is idempotent.
7. Repository shape is discovered, not selected from a frontend/backend taxonomy.
8. External workflow tools are optional adapters; the repository records one source of truth for each artifact.

## Optional workflow integrations

The playbook can coexist with Superpowers, Get Shit Done, GitHub Spec Kit, OpenSpec, and similar tools. They are not installed automatically. During bootstrap, the agent inventories existing integrations and either maps their artifacts to this workflow or recommends one option for human approval. See [`integrations.md`](integrations.md).

## Project-local skills

Bootstrap can install three thin execution skills for the coding agents configured in the target repository: canonical copies in `.agents/skills/` for Codex and Cursor and identical copies in `.claude/skills/` for Claude Code:

- `initialize-agent-workflow` — discover and reconcile local agent files and maps;
- `execute-task-workflow` — select a route and implement against canonical requirements;
- `review-task` — perform a fresh-context acceptance and code review.

The skill templates do not duplicate the methodology. They load the initialized repository's `docs/agent/*` artifacts, so local facts and the recorded playbook revision remain authoritative. Project-local installation is part of an explicit “initialize agents” request; user-global installation and third-party plugins require separate approval.

## Updating an initialized project

Use a pinned playbook release and ask the agent:

```text
Update this repository's agent workflow to agent-playbook v0.4.1. Read
bootstrap.md in that revision and follow its update procedure. Preserve local
rules and manual additions. Show the rules that changed, the final diff, and
validation results.
```

See [`bootstrap.md`](bootstrap.md#update-mode) for merge and conflict rules.

## Scope

This repository supplies instructions and templates; it does not automatically invoke another coding tool. Claude Code, Codex, and Cursor can exchange primary task artifacts through the target repository. Automated orchestration can be added later through CI or local scripts without changing the core workflow.

## License

[MIT](LICENSE)

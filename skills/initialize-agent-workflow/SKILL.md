---
name: initialize-agent-workflow
description: Initialize or update this repository's local agent workflow from the Agent Playbook. Use when asked to set up, bootstrap, refresh, or reconcile AGENTS.md, CLAUDE.md, project maps, capability maps, integrations, and project-local workflow skills, including new, empty repositories (interview and stack decision).
---

# Initialize Agent Workflow

Initialize the current target repository from the Agent Playbook without changing product code or replacing local policy.

## Source

Use the playbook source and revision supplied by the user. If the target repository already records a source and revision in `docs/agent/workflow.md`, use those for update mode. Otherwise ask for the source only when it cannot be discovered from the invocation context.

Read the source playbook's `bootstrap.md` in full and follow it as the authoritative procedure. Read `integrations.md` only when external workflow tooling is detected or requested. Read `greenfield.md` when the repository is greenfield.

## Required outcomes

- Inspect existing repository instructions, worktree changes, architecture boundaries, commands, CI, and representative examples before editing.
- Create or safely reconcile `AGENTS.md`, `CLAUDE.md`, `docs/agent/workflow.md`, `docs/agent/project-map.md`, and `docs/agent/capability-map.md` as directed by `bootstrap.md`.
- Create `docs/agent/integrations.md` only when an integration is active or approved.
- In a greenfield repository, interview the human, then create `docs/agent/product-brief.md`, `docs/adr/0001-stack.md`, maps with `planned` entries, and a scaffolding task card as directed by `greenfield.md`.
- Install project-local execution skills for the coding agents already configured in this repository, using the source templates under the playbook's `skills/` directory.
- Preserve manual content and more specific repository rules.
- Record the playbook source and pinned revision.
- Validate paths, commands, links, generated skill metadata, and a no-write second pass.

## Skill installation boundary

Project-local skill files are part of repository initialization. Install only adapters for tools evidenced in repository configuration or named by the user. Keep `.agents/skills/` as the canonical project-local copy when that convention is supported; create tool-specific generated copies or adapters only where the configured tool requires them.

Do not write to user-global skill directories, install third-party plugins, or run external tool initializers without explicit approval. Do not assume that `AGENTS.md` or `CLAUDE.md` proves a tool is installed; corroborate with repository configuration or the user's request.

Generated skill copies must record their source template and playbook revision. On update, refresh generated content while preserving manual files outside managed markers. Avoid duplicate skill names across active discovery locations.

## Completion report

Report files created or changed, detected agents and skill destinations, playbook revision, evidence inspected, validations actually run, unresolved facts, and the final diff summary.

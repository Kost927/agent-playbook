# Workflow Integration Map

Last verified against commit: `d182d60973bc7c796146478090d916ed088162c6`  
Verified on: `2026-11-21`  
Update the date and commit only when this file's facts change.

## Primary workflow owner

- Tool or core playbook: none — core playbook
- Version/revision: see `workflow.md`
- Canonical specification path: `docs/agent/tasks/`
- Canonical task-state path: `docs/agent/tasks/`
- Lifecycle commands: n/a — no methodology integration

## Active integrations

n/a — no methodology integration.

## Tools (MCP servers and plugins)

Every tool recommendation the owner answered during onboarding or later. Status is exactly one of these values, with no suffix: `configured`, `approved, owner installs`, or `declined`; the date goes in Approved on.

| Tool and version | Need | Scope | Config path | Status | Approved on |
| --- | --- | --- | --- | --- | --- |
| GitHub MCP (not pinned: declined) | Read CI results and pull requests (`.github/workflows/ci.yml`) | project | n/a | declined | 2026-11-21 |

## AI setup audit

User-level audit: declined (owner, 2026-11-21)

No decisions: the repository audit found nothing to decide (see `ONBOARDING.md`).

## Artifact mapping

n/a — no methodology integration; the playbook's task artifacts under `docs/agent/tasks/` are canonical.

## Commands and side effects

n/a — no methodology integration.

## Conflict policy

- Specification owner: core playbook (`docs/agent/tasks/`).
- Task/lifecycle owner: core playbook.
- Generated-instruction precedence: target repository instructions and accepted human decisions always win.
- Ambiguous overlap: stop and request a decision; do not run both workflows.

## Update and rollback

n/a — no tool is configured.

## Unknowns

- None.

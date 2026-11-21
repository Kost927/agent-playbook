# Workflow Integration Map

Last verified against commit: `<COMMIT_SHA>`  
Verified on: `<YYYY-MM-DD>`  
Update the date and commit only when this file's facts change.

## Primary workflow owner

- Tool or core playbook: `<name>`
- Version/revision: `<pinned value or verified current value>`
- Canonical specification path: `<path>`
- Canonical task-state path: `<path>`
- Lifecycle commands: `<documented commands>`

## Active integrations

| Tool | Scope | Owns | Must not own | Generated/config paths |
| --- | --- | --- | --- | --- |
| `<tool and version>` | `<repo/user/unit scope>` | `<non-overlapping role>` | `<explicit boundary>` | `<paths>` |

## Tools (MCP servers and plugins)

Every tool recommendation the owner answered during onboarding or later. Status is exactly one of these values, with no suffix: `configured`, `approved, owner installs`, or `declined`; the date goes in Approved on. An MCP-only adoption fills only this table; write `none — core playbook` as the primary workflow owner and `n/a — no methodology integration` in the methodology sections.

| Tool and version | Need | Scope | Config path | Status | Approved on |
| --- | --- | --- | --- | --- | --- |
| `<tool and pinned version>` | `<need found in the repository>` | `<project or user>` | `<config path or n/a>` | `<status>` | `<YYYY-MM-DD>` |

## AI setup audit

User-level audit: `<allowed or declined (owner, YYYY-MM-DD)>`

Decisions on findings from the playbook's `audit.md`. Location is exactly as `scripts/audit-ai-setup.sh` printed it; never a home path. A warning with decision `keep` is reported as accepted on later runs.

| Kind | Location | Decision | Source |
| --- | --- | --- | --- |
| `<script kind or judgment: slug>` | `<location>` | `<keep, remove, rename, merge, or primary owner>` | `<owner, YYYY-MM-DD>` |

## Artifact mapping

| Playbook artifact/concept | Canonical integration artifact | Notes |
| --- | --- | --- |
| Original request | `<path/link>` | `<preservation rule>` |
| Specification and acceptance criteria | `<path>` | `<IDs/format>` |
| Design/contract decisions | `<path>` | `<relationship>` |
| Task state | `<path>` | `<lifecycle owner>` |
| Handoff | `<path>` | `<fresh-context inputs>` |
| Review evidence | `<path>` | `<independent reviewer rule>` |

## Commands and side effects

| Command | Purpose | Files/state changed | Approval or safety notes |
| --- | --- | --- | --- |
| `<command>` | `<purpose>` | `<known effects>` | `<constraints>` |

## Conflict policy

- Specification owner: `<one source>`
- Task/lifecycle owner: `<one source>`
- Generated-instruction precedence: target repository instructions and accepted human decisions always win.
- Ambiguous overlap: stop and request a decision; do not run both workflows.

## Update and rollback

- Update procedure: `<official documented procedure and pin policy>`
- Removal/disable procedure: `<official documented procedure>`
- Artifacts retained after removal: `<requirements/history that must remain>`

## Unknowns

- `<unverified scope, version, ownership, or side effect>`

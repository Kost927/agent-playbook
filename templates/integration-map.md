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

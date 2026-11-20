# Project Map

Last verified against commit: `<COMMIT_SHA>`  
Verified on: `<YYYY-MM-DD>`

Status: `verified` = found in the repository or executed; `planned` = decided but not yet present (greenfield). Allowed values: `planned | verified`.

## Repository shape

- Repository shape: `<single unit | multiple units | monorepo | other verified description>`
- Primary runtime(s): `<verified versions or unknown>`
- Package/build system: `<verified tool and evidence>`
- Top-level modules: `<paths and responsibilities>`

## Entry points and boundaries

| Concern | Path | Evidence and notes | Status |
| --- | --- | --- | --- |
| Application entry | `<path>` | `<what was verified>` | `<planned/verified>` |
| Interface/contract entry | `<path>` | `<what was verified>` | `<planned/verified>` |
| Shared code | `<path>` | `<ownership/boundary>` | `<planned/verified>` |

## Components and dependency graph

Document independently built, tested, deployed, published, or owned units and the allowed dependency direction between them. For a monorepo, include package boundaries and the commands that operate at root versus package scope.

## Contracts, data, and state

Document externally observable interfaces, schemas/contracts, persistence, messages, state ownership, generation, caching, and error handling with file evidence. Use “unknown” where evidence is unavailable.

## Good examples

| Convention | Example path | Why this is the preferred example | Status |
| --- | --- | --- | --- |
| `<convention>` | `<path>` | `<specific behavior to copy>` | `<planned/verified>` |

## Verified commands

| Purpose | Command | Evidence | Status | Last result |
| --- | --- | --- | --- | --- |
| Install | `<command or not documented>` | `<manifest/CI path>` | `<planned/verified>` | `<run result or not run>` |
| Static analysis | `<command or unavailable>` | `<path>` | `<planned/verified>` | `<result>` |
| Format/lint | `<command or unavailable>` | `<path>` | `<planned/verified>` | `<result>` |
| Test | `<command or unavailable>` | `<path>` | `<planned/verified>` | `<result>` |
| Build | `<command or unavailable>` | `<path>` | `<planned/verified>` | `<result>` |
| System/acceptance | `<command or unavailable>` | `<path>` | `<planned/verified>` | `<result>` |

## Delivery and operations

Record verified CI, release, deployment, rollback, feature-flag, logging, metric, and alert paths. Do not infer production scale or operational constraints from local code.

## Known discrepancies and unknowns

- `<documentation/configuration mismatch>`
- `<fact requiring a human or external system>`

## Maintenance triggers

Update this map when commands, entry points, module boundaries, major dependencies, contracts, or preferred examples change.

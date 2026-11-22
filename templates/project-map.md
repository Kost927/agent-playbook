# Project Map

Last verified against commit: `<COMMIT_SHA>`  
Verified on: `<YYYY-MM-DD>`  
Update the date and commit only when this file's facts change.

Status: `verified` = found in the repository or executed; `planned` = decided but not yet present (greenfield). `unknown` = not yet decided or discovered. Allowed values: `planned | verified | unknown`. Absent tooling (no linter, no build step) is `unknown` with "none found" as its evidence.

## Repository shape

- Repository shape: `<single unit | multiple units | monorepo | other verified description>`
- Primary runtime(s): `<verified versions or unknown>`
- Package/build system: `<verified tool and evidence>`
- Top-level modules: `<paths and responsibilities>`

## Entry points and boundaries

| Concern | Path | Evidence and notes | Status |
| --- | --- | --- | --- |
| Application entry | `<path>` | `<what was verified>` | `<planned/verified/unknown>` |
| Interface/contract entry | `<path>` | `<what was verified>` | `<planned/verified/unknown>` |
| Shared code | `<path>` | `<ownership/boundary>` | `<planned/verified/unknown>` |

## Components and dependency graph

<!-- template: Document independently built, tested, deployed, published, or owned units and the allowed dependency direction between them. For a monorepo, include package boundaries and the commands that operate at root versus package scope. -->

## Contracts, data, and state

<!-- template: Document externally observable interfaces, schemas/contracts, persistence, messages, state ownership, generation, caching, and error handling with file evidence. Use “unknown” where evidence is unavailable. -->

## Good examples

| Convention | Example path | Why this is the preferred example | Status |
| --- | --- | --- | --- |
| `<convention>` | `<path>` | `<specific behavior to copy>` | `<planned/verified/unknown>` |

## Verified commands

| Purpose | Command | Evidence | Status | Last result |
| --- | --- | --- | --- | --- |
| Install | `<command or not documented>` | `<manifest/CI path>` | `<planned/verified/unknown>` | `<run result or not run>` |
| Static analysis | `<command or unavailable>` | `<path>` | `<planned/verified/unknown>` | `<result>` |
| Format/lint | `<command or unavailable>` | `<path>` | `<planned/verified/unknown>` | `<result>` |
| Test | `<command or none found>` | `<path>` | `<planned/verified/unknown>` | `<result>` |
| Build | `<command or unavailable>` | `<path>` | `<planned/verified/unknown>` | `<result>` |
| System/acceptance | `<command or unavailable>` | `<path>` | `<planned/verified/unknown>` | `<result>` |
| Security: static analysis (SAST) | `<command or none found>` | `<CI or config path>` | `<planned/verified/unknown>` | `<result>` |
| Security: dependency audit | `<command or none found>` | `<CI or config path>` | `<planned/verified/unknown>` | `<result>` |
| Security: dynamic scan (DAST) | `<command or none found>` | `<CI or config path>` | `<planned/verified/unknown>` | `<result>` |
| Quality: mutation testing | `<command or none found>` | `<CI or config path>` | `<planned/verified/unknown>` | `<result>` |

## Delivery and operations

- Staging or preview environment: `<how to deploy and reach it, or none found>`
- Agents may use it for acceptance checks: `<yes, with the test account name or mode (never a password); no; n/a — none exists; or not asked>`
- Test account credentials: `<environment variable names or secret store, never values; or none>`
- Branches that deploy on push or merge: `<branch → environment, from CI or deploy configuration; or none found>`

<!-- template: Record verified CI, release, deployment, rollback, feature-flag, logging, metric, and alert paths. Do not infer production scale or operational constraints from local code. -->

## Known discrepancies and unknowns

- `<documentation/configuration mismatch>`
- `<fact requiring a human or external system>`

## Maintenance triggers

Update this map when commands, entry points, module boundaries, major dependencies, contracts, or preferred examples change.

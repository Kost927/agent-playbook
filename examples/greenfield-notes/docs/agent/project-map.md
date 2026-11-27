# Project Map

Last verified against commit: `none (the repository has only README.md, not yet committed)`  
Verified on: `2026-11-21`  
Update the date and commit only when this file's facts change.

Status: `verified` = found in the repository or executed; `planned` = decided but not yet present (greenfield). `unknown` = not yet decided or discovered. Allowed values: `planned | verified | unknown`. Absent tooling (no linter, no build step) is `unknown` with "none found" as its evidence.

## Repository shape

- Repository shape: planned single unit, one Node.js service (ADR-0001).
- Primary runtime(s): Node.js, version unknown until scaffolding.
- Package/build system: npm (planned, ADR-0001).
- Top-level modules: unknown until scaffolding.

## Entry points and boundaries

| Concern | Path | Evidence and notes | Status |
| --- | --- | --- | --- |
| Application entry | unknown | Node.js HTTP server with server-rendered pages (ADR-0001) | planned |
| Interface/contract entry | unknown | Web pages behind Google sign-in; no public API in the first milestone (product brief) | planned |
| Shared code | unknown | Not decided | unknown |

## Components and dependency graph

One planned unit: web server, SQLite storage with full-text search, Google sign-in (ADR-0001). Module boundaries are decided during scaffolding.

## Contracts, data, and state

- Data: notes in SQLite with FTS5 full-text search (planned, ADR-0001). Note fields and schema are unknown (an agent proposal of title and body is not yet decided).
- Authentication: Google Workspace sign-in required for every page (planned, product brief).
- Sensitive data: none expected; internal procedures only (product brief).

## Good examples

| Convention | Example path | Why this is the preferred example | Status |
| --- | --- | --- | --- |
| None yet | none found | No code exists | unknown |

## Verified commands

| Purpose | Command | Evidence | Status | Last result |
| --- | --- | --- | --- | --- |
| Install | `npm ci` | ADR-0001 | planned | not run |
| Static analysis | `npm run typecheck` | ADR-0001 | planned | not run |
| Format/lint | `npm run lint` | ADR-0001 | planned | not run |
| Targeted checks (changed files) | not decided | none found | unknown | not run |
| Test | `npm test` | ADR-0001 | planned | not run |
| Build | `npm run build` | ADR-0001 | planned | not run |
| System/acceptance | not decided | none found | unknown | not run |
| Security: static analysis (SAST) | not decided | none found | unknown | not run |
| Security: dependency audit | not decided | none found | unknown | not run |
| Security: dynamic scan (DAST) | not decided | none found | unknown | not run |
| Quality: mutation testing | not decided | none found | unknown | not run |

Typical duration: none measured (no code yet).

## Delivery and operations

- Deployment: one Docker container on the existing Linux VM (planned, product brief and ADR-0001).
- CI, release, rollback, logging, metrics, alerts: not decided (unknown).
- Staging or preview environment: none (owner, 2026-11-21).
- Agents may use it for acceptance checks: not asked yet; decide after scaffolding (unknown).
- Test account credentials: not decided (unknown).
- Branches that deploy on push or merge: not decided; deployment to the VM is planned in ADR-0001 (planned).
- Other deploy triggers: not decided (unknown).

## Known discrepancies and unknowns

- ADR-0001 is `proposed`; every planned entry depends on its confirmation.
- Who can deploy to the VM.
- Node.js version and test framework.

## Maintenance triggers

Update this map when commands, entry points, module boundaries, major dependencies, contracts, or preferred examples change.

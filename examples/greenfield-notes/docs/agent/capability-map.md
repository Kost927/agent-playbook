# Capability Map

Last verified against commit: `none (the repository has only README.md, not yet committed)`  
Verified on: `2026-11-21`  
Update the date and commit only when this file's facts change.

Status: `verified` = found in the repository or executed; `planned` = decided but not yet present (greenfield). `unknown` = not yet decided or discovered. Allowed values: `planned | verified | unknown`. Absent tooling (no linter, no build step) is `unknown` with "none found" as its evidence.

This map is derived from repository evidence. It is not a fixed frontend/backend classification.

## Units and boundaries

| Unit or subsystem | Paths | Built/tested/deployed/published as | Dependencies and consumers | Status |
| --- | --- | --- | --- | --- |
| Team Notes web service | unknown until scaffolding | Docker image deployed to the existing VM | Used by the support team through a browser | planned |

## Detected capability workstreams

| Workstream | Scope and entry points | Contracts/invariants | Validation and good examples | Status |
| --- | --- | --- | --- | --- |
| Interaction surface | Server-rendered pages for creating, editing, deleting, and searching notes | Search returns relevant notes quickly for a small team (product brief success criteria) | Not decided | planned |
| Data and state | SQLite with full-text search | Notes persist across restarts; schema changes through migrations (to be chosen) | Not decided | planned |
| Security | Google Workspace sign-in on every page | No page is reachable without company login | Not decided | planned |
| Infrastructure and delivery | One Docker container on the existing VM | Deployment does not require paid services | Not decided | planned |

Only include workstreams supported by evidence, or `planned` workstreams traced to the product brief or stack ADR. One unit may have multiple rows.

## Cross-cutting concerns

- Authentication applies to every page; any public page would need a new decision and the Full route.

## Scope rules

- Root commands and policy: planned npm scripts (project map).
- Unit-scoped commands and policy: not applicable (single planned unit).
- Affected/dependent-unit selection: not applicable.
- Nested instruction boundaries: none.

## Unknowns and external facts

- Confirmation of ADR-0001.
- Backup expectations for the SQLite file on the VM.

## Maintenance triggers

Update this map when units, interfaces, dependency direction, commands, ownership, compatibility promises, deployment topology, or cross-cutting policy changes.

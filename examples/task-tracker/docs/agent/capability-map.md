# Capability Map

Last verified against commit: `1bfc74bf6a7aca263e476507c58dca9830236c5f`  
Verified on: `2026-11-21`  
Update the date and commit only when this file's facts change.

Status: `verified` = found in the repository or executed; `planned` = decided but not yet present (greenfield). `unknown` = not yet decided or discovered. Allowed values: `planned | verified | unknown`.

This map is derived from repository evidence. It is not a fixed frontend/backend classification.

## Units and boundaries

| Unit or subsystem | Paths | Built/tested/deployed/published as | Dependencies and consumers | Status |
| --- | --- | --- | --- | --- |
| `tracker` package | `src/tracker/`, `migrations/`, `tests/` | Tested by CI; not built, published, or deployed | Consumers of the HTTP API and CLI are unknown | verified |

## Detected capability workstreams

| Workstream | Scope and entry points | Contracts/invariants | Validation and good examples | Status |
| --- | --- | --- | --- | --- |
| Service and contract boundaries | `src/tracker/api.py` | Routes, status codes, and JSON shapes listed in the project map; errors are `{"error": str}` | `tests/test_api.py` | verified |
| Interaction surface (CLI) | `src/tracker/cli.py` | Subcommands, output format `[x] <id> <title>`, exit code 1 for a missing task | `tests/test_cli.py` | verified |
| Data and state | `src/tracker/db.py`, `migrations/` | `tasks.title` non-empty; migrations applied once, in filename order; existing migrations are never edited | `tests/test_db.py` (`test_reconnect_keeps_data`) | verified |
| Infrastructure and delivery | `.github/workflows/ci.yml` | CI runs the full test suite on push and pull request | CI workflow | verified |

## Cross-cutting concerns

- Security: no authentication; the API binds to `127.0.0.1`. Any change exposing it beyond localhost activates the security workstream and the Full route.
- Concurrency: one shared SQLite connection behind a lock inside the API process.

## Scope rules

- Root commands and policy: test command in the project map; single unit.
- Unit-scoped commands and policy: not applicable (single unit).
- Affected/dependent-unit selection: not applicable (single unit).
- Nested instruction boundaries: none.

## Unknowns and external facts

- Who consumes the HTTP API or CLI, and whether compatibility must be preserved for them.
- Production deployment, data volume, and backup expectations.

## Maintenance triggers

Update this map when units, interfaces, dependency direction, commands, ownership, compatibility promises, deployment topology, or cross-cutting policy changes.

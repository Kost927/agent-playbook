# Capability Map

Last verified against commit: `d182d60973bc7c796146478090d916ed088162c6`  
Verified on: `2026-11-21`  
Update the date and commit only when this file's facts change.

Status: `verified` = found in the repository or executed; `planned` = decided but not yet present (greenfield). `unknown` = not yet decided or discovered. Allowed values: `planned | verified | unknown`. Absent tooling (no linter, no build step) is `unknown` with "none found" as its evidence.

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
| Data and state | `src/tracker/db.py`, `migrations/` | `tasks.title` non-empty; migrations applied once, atomically, in filename order; existing migrations are never edited | `tests/test_db.py` (`test_reconnect_keeps_data`, `test_concurrent_connect_applies_migration_once`) | verified |
| Infrastructure and delivery | `.github/workflows/ci.yml` | CI runs the full test suite on push and pull request when this directory is the repository root | CI workflow | verified |

Only include workstreams supported by evidence, or `planned` workstreams traced to the product brief or stack ADR. One unit may have multiple rows.

Design system: none found (the only human-facing surface is the CLI). Reuse the existing CLI output format in `src/tracker/cli.py`.

## Cross-cutting concerns

- Security: no authentication; the API binds to `127.0.0.1`. Any change exposing it beyond localhost activates the security workstream and the Full route.
- Concurrency: the API server is single-threaded; concurrent processes are serialized by SQLite locking.

## Risk zones

Owner-stated during onboarding (see [`ONBOARDING.md`](../../ONBOARDING.md)). A task that changes a listed path starts at that zone's minimum route.

| Zone | Paths | Why | Minimum route | Source |
| --- | --- | --- | --- | --- |
| Migrations | `migrations/` | Changes durable data; existing migrations are never edited | Standard | owner, 2026-11-21 |

Considered, not risk zones: `src/tracker/db.py` (owner, 2026-11-21).

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

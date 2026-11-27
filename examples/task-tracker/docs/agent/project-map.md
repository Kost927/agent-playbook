# Project Map

Last verified against commit: `d182d60973bc7c796146478090d916ed088162c6`  
Verified on: `2026-11-21`  
Update the date and commit only when this file's facts change.

Status: `verified` = found in the repository or executed; `planned` = decided but not yet present (greenfield). `unknown` = not yet decided or discovered. Allowed values: `planned | verified | unknown`. Absent tooling (no linter, no build step) is `unknown` with "none found" as its evidence.

## Repository shape

- Repository shape: single unit — one Python package, `tracker`, with two entry points (HTTP API and CLI) over one SQLite store.
- Primary runtime(s): Python `>=3.9` (`pyproject.toml`); CI runs Python 3.12 (`.github/workflows/ci.yml`).
- Package/build system: `pyproject.toml` metadata only; no `[build-system]` table, no lockfile, no third-party dependencies. Not packaged for installation: run from a checkout with `PYTHONPATH=src`.
- Top-level modules: `src/tracker/db.py` (storage and migrations), `src/tracker/api.py` (HTTP API), `src/tracker/cli.py` (CLI), `migrations/` (SQL), `tests/` (unittest).

## Entry points and boundaries

| Concern | Path | Evidence and notes | Status |
| --- | --- | --- | --- |
| Application entry (HTTP) | `src/tracker/api.py` | `serve()` binds `127.0.0.1:8000`; run as `python3 -m tracker.api` | verified |
| Application entry (CLI) | `src/tracker/cli.py` | `main(argv)`; run as `python3 -m tracker.cli` | verified |
| Interface/contract entry | `src/tracker/api.py` module docstring | Routes and status codes for `/tasks` and `/tasks/<id>/complete` | verified |
| Shared code | `src/tracker/db.py` | Used by both API and CLI; owns schema and migration application | verified |

## Components and dependency graph

One unit. Dependency direction: `api` → `db`, `cli` → `db`; `db` depends only on the standard library and `migrations/*.sql`. API and CLI must not depend on each other.

## Contracts, data, and state

- HTTP contract: `GET /tasks` → 200 JSON list of `{id, title, done}`; `POST /tasks` with `{"title": str}` → 201 `{id}`, 400 `{error}` for invalid JSON, nesting too deep, invalid `Content-Length`, or missing/blank title; 408 `{error}` when the body is shorter than `Content-Length` (5-second request timeout); `POST /tasks/<id>/complete` → 204 or 404 `{error}`; other paths → 404. Source: `src/tracker/api.py`, `tests/test_api.py`.
- CLI contract: `python3 -m tracker.cli [--db PATH] add <title> | list | done <id>`; `add` with a blank title and `done` on a missing id print to stderr and exit 1. Source: `src/tracker/cli.py`, `tests/test_cli.py`.
- Persistence: SQLite file (default `tracker.db`). Table `tasks` from `migrations/001_init.sql`; `db.connect()` applies pending migrations in filename order inside one `BEGIN IMMEDIATE` transaction and records them in `schema_migrations`, so concurrent processes apply each migration once. Statements are split with `sqlite3.complete_statement`, so comments and quoted semicolons are safe.
- Concurrency: `HTTPServer` handles one request at a time; the API's single connection is also guarded by a lock. Concurrent processes (API and CLI) are serialized by SQLite locking.
- Authentication: none; the API binds to localhost only.

## Good examples

| Convention | Example path | Why this is the preferred example | Status |
| --- | --- | --- | --- |
| API error responses | `src/tracker/api.py` `create_task` | JSON `{"error": ...}` with explicit status; validation before writing | verified |
| HTTP tests | `tests/test_api.py` | Real server on port 0 in a thread; asserts status and body | verified |
| Schema change | `migrations/001_init.sql` | New numbered SQL file; `db.connect()` applies it once | verified |

## Verified commands

| Purpose | Command | Evidence | Status | Last result |
| --- | --- | --- | --- | --- |
| Install | not needed (standard library only) | `pyproject.toml` `dependencies = []` | verified | not applicable |
| Static analysis | none found | no configuration in the repository | unknown | not run |
| Format/lint | none found | no configuration in the repository | unknown | not run |
| Targeted checks (changed files) | `PYTHONPATH=src python3 -m unittest tests.test_<module>` for the changed module (for example `tests.test_api`) | derived from `tests/test_<module>.py`; `tests.test_api` run | verified | passed, 10 tests (2026-11-27) |
| Test | `PYTHONPATH=src python3 -m unittest discover -s tests -t .` | `.github/workflows/ci.yml`, `README.md` | verified | passed, 21 tests (2026-11-21) |
| Build | none found | no `[build-system]` table | unknown | not run |
| System/acceptance | `PYTHONPATH=src python3 -m tracker.cli --db <path> add "..."` then `list` | `README.md` | verified | passed manually (2026-11-21) |
| Security: static analysis (SAST) | none found | no scanner in CI or configuration | unknown | not run |
| Security: dependency audit | none found | `pyproject.toml` (`dependencies = []`) | unknown | not run |
| Security: dynamic scan (DAST) | none found | no scanner in CI or configuration | unknown | not run |
| Quality: mutation testing | none found | no tool in CI or configuration | unknown | not run |

Typical duration: none measured; the full test suite takes seconds.

## Delivery and operations

- CI: `.github/workflows/ci.yml` runs the test command on push and pull request (Python 3.12) when this directory is the repository root. Inside the playbook repository it does not run; the playbook's own CI runs these tests instead.
- Release, deployment, rollback, logging, metrics, alerts: none in the repository (unknown).
- Staging or preview environment: none (owner, 2026-11-21); none found in the repository.
- Agents may use it for acceptance checks: n/a — no staging or preview environment; local CLI checks only.
- Test account credentials: none; the CLI needs no credentials.
- Branches that deploy on push or merge: none found; CI only runs tests (`.github/workflows/ci.yml`).
- Other deploy triggers: none found.

## Known discrepancies and unknowns

- Local minimum Python is 3.9 (`pyproject.toml`) but CI only tests 3.12.
- No lint, format, type-check, or build configuration.
- Production use, scale, and multi-process access to the database are unknown.

## Maintenance triggers

Update this map when commands, entry points, module boundaries, major dependencies, contracts, or preferred examples change.

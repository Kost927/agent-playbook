# Project Map

Last verified against commit: `1bfc74bf6a7aca263e476507c58dca9830236c5f`  
Verified on: `2026-11-21`  
Update the date and commit only when this file's facts change.

Status: `verified` = found in the repository or executed; `planned` = decided but not yet present (greenfield). `unknown` = not yet decided or discovered. Allowed values: `planned | verified | unknown`.

## Repository shape

- Repository shape: single unit — one Python package, `tracker`, with two entry points (HTTP API and CLI) over one SQLite store.
- Primary runtime(s): Python `>=3.9` (`pyproject.toml`); CI runs Python 3.12 (`.github/workflows/ci.yml`).
- Package/build system: `pyproject.toml` with setuptools package discovery under `src/`. No `[build-system]` table and no lockfile; the project has no third-party dependencies.
- Top-level modules: `src/tracker/db.py` (storage and migrations), `src/tracker/api.py` (HTTP API), `src/tracker/cli.py` (CLI), `migrations/` (SQL), `tests/` (unittest).

## Entry points and boundaries

| Concern | Path | Evidence and notes | Status |
| --- | --- | --- | --- |
| Application entry (HTTP) | `src/tracker/api.py` | `serve()` binds `127.0.0.1:8000`; run as `python3 -m tracker.api` | verified |
| Application entry (CLI) | `src/tracker/cli.py` | `main(argv)`; `[project.scripts] tracker` in `pyproject.toml` | verified |
| Interface/contract entry | `src/tracker/api.py` module docstring | Routes and status codes for `/tasks` and `/tasks/<id>/complete` | verified |
| Shared code | `src/tracker/db.py` | Used by both API and CLI; owns schema and migration application | verified |

## Components and dependency graph

One unit. Dependency direction: `api` → `db`, `cli` → `db`; `db` depends only on the standard library and `migrations/*.sql`. API and CLI must not depend on each other.

## Contracts, data, and state

- HTTP contract: `GET /tasks` → 200 JSON list of `{id, title, done}`; `POST /tasks` with `{"title": str}` → 201 `{id}`, 400 `{error}` for invalid JSON or missing/blank title; `POST /tasks/<id>/complete` → 204 or 404 `{error}`; other paths → 404. Source: `src/tracker/api.py`, `tests/test_api.py`.
- CLI contract: `tracker [--db PATH] add <title> | list | done <id>`; `done` on a missing id prints to stderr and exits 1. Source: `src/tracker/cli.py`, `tests/test_cli.py`.
- Persistence: SQLite file (default `tracker.db`). Table `tasks` from `migrations/001_init.sql`; applied migrations are tracked in `schema_migrations` by `db.connect()`, in filename order.
- Concurrency: the API shares one connection guarded by a `threading.Lock`; multi-process access to the same file is not addressed (unknown).
- Authentication: none; the API binds to localhost only.

## Good examples

| Convention | Example path | Why this is the preferred example | Status |
| --- | --- | --- | --- |
| API error responses | `src/tracker/api.py` `create_task` | JSON `{"error": ...}` with explicit status; validation before writing | verified |
| HTTP tests | `tests/test_api.py` | Real server on port 0 in a thread; asserts status and body | verified |
| Schema change | `migrations/001_init.sql` | New numbered SQL file; `db.connect()` applies it once | verified |

## Verified commands

Run from the repository root.

| Purpose | Command | Evidence | Status | Last result |
| --- | --- | --- | --- | --- |
| Install | not needed (standard library only) | `pyproject.toml` `dependencies = []` | verified | not applicable |
| Static analysis | unavailable | no configuration found | unknown | not run |
| Format/lint | unavailable | no configuration found | unknown | not run |
| Test | `PYTHONPATH=src python3 -m unittest discover -s tests -t .` | `.github/workflows/ci.yml`, `README.md` | verified | passed, 11 tests (2026-11-21) |
| Build | not documented | no `[build-system]` table | unknown | not run |
| System/acceptance | `PYTHONPATH=src python3 -m tracker.cli --db <path> add "..."` then `list` | `README.md` | verified | passed manually (2026-11-21) |

## Delivery and operations

- CI: `.github/workflows/ci.yml` runs the test command on push and pull request (Python 3.12).
- Release, deployment, rollback, logging, metrics, alerts: none in the repository (unknown).

## Known discrepancies and unknowns

- Local minimum Python is 3.9 (`pyproject.toml`) but CI only tests 3.12.
- No lint, format, type-check, or build configuration.
- Production use, scale, and multi-process access to the database are unknown.

## Maintenance triggers

Update this map when commands, entry points, module boundaries, major dependencies, contracts, or preferred examples change.

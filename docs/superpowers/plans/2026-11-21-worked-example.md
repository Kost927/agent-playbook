# Worked Example Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a synthetic example repository, initialize it by following `bootstrap.md` literally, record friction, and prepare the first release tag.

**Architecture:** `examples/task-tracker/` is a self-contained stdlib-only Python project. Its generated agent docs are committed beside the code. `scripts/validate.sh` runs the example's tests and checks generated docs for leftover placeholders.

**Tech Stack:** Python ≥ 3.10 stdlib (`sqlite3`, `http.server`, `argparse`, `unittest`), Markdown, Bash.

**Spec:** `docs/superpowers/specs/2026-11-21-worked-example-design.md`

## Global Constraints

- No third-party dependencies; tests run with `python3 -m unittest discover -s tests -t .` from `examples/task-tracker`.
- Generated docs follow the templates; no `` `< `` placeholders remain; unverified commands are not marked verified.
- Do not commit `.agents/skills/` or `.claude/skills/` in the example.
- Do not fix `TRIAL.md` findings in this plan.
- Tag `v0.1.0` locally only; push needs approval.
- Markdown links in this plan are code spans.

## Review Focus

- `validate.sh` run from a different working directory → example tests still found (Task 1 uses absolute paths).
- Example API given invalid JSON or missing title → 400 with JSON error, not a crash (Task 1 test).
- Completing a missing task id → 404 (Task 1 test).
- Generated `project-map.md` lists a command never executed → must say "not run", not verified (Task 2 check).
- `CLAUDE.md` in example imports `AGENTS.md` exactly once (Task 2 check).

---

### Task 1: Example repository

**Files:**
- Create: `examples/task-tracker/{pyproject.toml,README.md,migrations/001_init.sql,src/tracker/__init__.py,src/tracker/db.py,src/tracker/api.py,src/tracker/cli.py,tests/__init__.py,tests/test_db.py,tests/test_api.py,tests/test_cli.py,.github/workflows/ci.yml}`
- Modify: `scripts/validate.sh`

**Interfaces:**
- `tracker.db`: `connect(path: str) -> sqlite3.Connection` (applies migrations), `add_task(conn, title: str) -> int`, `list_tasks(conn) -> list[dict]` (keys `id`, `title`, `done`), `complete_task(conn, task_id: int) -> bool`.
- `tracker.api`: `make_handler(db_path: str) -> type[BaseHTTPRequestHandler]`; routes `GET /tasks` → 200 list; `POST /tasks` `{"title": str}` → 201 `{"id": int}`, invalid → 400 `{"error": str}`; `POST /tasks/<id>/complete` → 204, missing → 404.
- `tracker.cli`: `main(argv: list[str]) -> int`; subcommands `add <title>`, `list`, `done <id>`; `--db PATH` (default `tracker.db`).

- [ ] **Step 1:** In `validate.sh` add: run `python3 -m unittest discover -s tests -t .` with `cwd` = `$repository_root/examples/task-tracker` and `PYTHONPATH=src`; fail with `example tests failed`.
- [ ] **Step 2:** Run `bash scripts/validate.sh`. Expected: fails (directory missing).
- [ ] **Step 3:** Write tests: db add/list/complete, complete missing → False; API via a server on port 0 in a thread: create, list, complete, invalid JSON → 400, missing title → 400, missing id → 404; CLI add/list/done with a temp db, `done 999` → exit 1.
- [ ] **Step 4:** Run tests. Expected: import errors (modules missing).
- [ ] **Step 5:** Implement `db.py`, `api.py`, `cli.py`, migration, `pyproject.toml`, CI workflow (ubuntu, Python 3.12, same test command), short README.
- [ ] **Step 6:** Run `bash scripts/validate.sh`. Expected: exit 0.
- [ ] **Step 7:** Commit: "Add task-tracker example repository".

### Task 2: Trial run of bootstrap

**Files:**
- Create: `examples/task-tracker/{AGENTS.md,CLAUDE.md,docs/agent/workflow.md,docs/agent/project-map.md,docs/agent/capability-map.md,TRIAL.md}`
- Modify: `examples/task-tracker/README.md`, `scripts/validate.sh`

- [ ] **Step 1:** In `validate.sh` require the six files above; fail if any of the generated docs (not `TRIAL.md`) contains `` `< ``; fail unless `CLAUDE.md` contains `@AGENTS.md` exactly once.
- [ ] **Step 2:** Run `bash scripts/validate.sh`. Expected: missing-file failure.
- [ ] **Step 3:** Follow `bootstrap.md` steps 1–7 literally against `examples/task-tracker` (treat it as the repository root). Record playbook revision = current `main` SHA. Write generated files from the templates. Record every unclear or contradictory step in `TRIAL.md` as rows: step | issue | what I did | suggested fix.
- [ ] **Step 4:** Add "Agent workflow files" section to the example README: list generated files and note that bootstrap would also create `.agents/skills/*` and `.claude/skills/*` (omitted here).
- [ ] **Step 5:** Run `bash scripts/validate.sh`. Expected: exit 0.
- [ ] **Step 6:** Commit: "Initialize task-tracker example via bootstrap trial run".

### Task 3: README release references

**Files:**
- Modify: `README.md`

- [ ] **Step 1:** Add `examples/` to "Repository contents" with a link to `examples/task-tracker/`; add a sentence in Quick start pointing to the example as "what a result looks like".
- [ ] **Step 2:** Replace `agent-playbook v1.2` with `agent-playbook v0.1.0` in the update prompt.
- [ ] **Step 3:** Run `bash scripts/validate.sh`. Expected: exit 0.
- [ ] **Step 4:** Commit: "Reference example and v0.1.0 in README".

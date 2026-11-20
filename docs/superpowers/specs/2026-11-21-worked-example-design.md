# Worked Example and Trial Run — Design

Date: 2026-11-21
Status: approved

## Intent

The playbook has no example of an initialized repository and has never been run end to end. Agents follow concrete examples better than abstract rules, and the playbook needs a regression check. A committed synthetic repository, initialized by following `bootstrap.md` literally, provides both, plus a list of real friction in the procedure.

## Goals

- `examples/task-tracker/`: a small, realistic, dependency-free repository.
- Run `bootstrap.md` literally against it and commit the generated `AGENTS.md`, `CLAUDE.md`, and `docs/agent/*`.
- `examples/task-tracker/TRIAL.md`: every place where `bootstrap.md` was unclear or contradictory, as input for later playbook fixes.
- `scripts/validate.sh` runs the example's tests so "verified" commands stay true.
- Replace the fictional `v1.2` in README; tag `v0.1.0` locally after merge.

## Non-goals

- A greenfield interview example (possible later item).
- Committing generated skill copies (`.agents/skills/`, `.claude/skills/`) in the example.
- Fixing the friction found in `TRIAL.md` within this item.
- Pushing the tag without explicit approval.

## Anti-goals

- A toy repository that activates no meaningful workstreams.
- Generated docs that contain unfilled template placeholders or claim unverified commands as verified.

## Approaches considered

| Option | Trade-off | Decision |
| --- | --- | --- |
| A. Synthetic repo in `examples/` | Controlled and publishable; less realistic | **Chosen** |
| B. A real user project | Realistic; private code cannot be committed | Rejected |
| C. Both | Most useful; slowest | Rejected for now |

## Design

### Example repository

Python, standard library only:

- `pyproject.toml` (project metadata, Python ≥ 3.10);
- `src/tracker/db.py` — SQLite access; `migrations/001_init.sql`;
- `src/tracker/api.py` — JSON HTTP API (`http.server`): list, create, complete tasks;
- `src/tracker/cli.py` — CLI over the same store;
- `tests/` — `unittest` tests for store, API, CLI;
- `.github/workflows/ci.yml` — runs the tests;
- `README.md` — short, as a real project would have.

Expected workstreams: service/contract (HTTP API), data and state (SQLite + migration), interaction surface (CLI), infrastructure and delivery (CI).

### Trial run

Follow `bootstrap.md` step by step as an agent in that repository. Generated files are committed next to the code. The example `README.md` gains a short section listing generated files and the skill copies that bootstrap would also create.

### `TRIAL.md`

Per finding: bootstrap step, what was unclear, what the agent did, suggested fix.

### Validation

`scripts/validate.sh` runs `python3 -m unittest discover` in the example and checks that generated docs contain no `` `< `` placeholders.

### Release

README update instructions reference a real tag. After merge, create local tag `v0.1.0`; push only with approval.

## Left to the builder

- Exact API routes, CLI commands, and test cases.
- Wording of generated docs (must follow templates).

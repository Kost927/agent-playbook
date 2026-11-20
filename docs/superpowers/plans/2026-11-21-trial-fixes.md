# Trial-Run Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Resolve the nine trial-run findings and make initialized repositories mechanically checkable.

**Architecture:** Text fixes in `bootstrap.md`, templates, profile, and README; two new entry-point templates; a new `scripts/check-target.sh` used by bootstrap and by `validate.sh` on the example.

**Tech Stack:** Markdown, Bash + inline Python 3.9+.

**Spec:** `docs/superpowers/specs/2026-11-21-trial-fixes-design.md`

## Global Constraints

- Placeholder rule: a template line containing `` `<...>` `` matches a target line where each such span is any non-empty code span; all other text must match exactly.
- Entry-point templates carry `agent-playbook` markers; only the test command is repository-specific.
- The checker never writes.
- `bash scripts/validate.sh` exits 0 after every task. Markdown links in this plan are code spans.

## Review Focus

- Target with `CLAUDE.md` symlinked to `AGENTS.md` → checker passes (Task 2 test).
- Target with no `CLAUDE.md` at all (Codex only) → checker passes (Task 2 test).
- Managed block edited by hand inside markers → checker fails (Task 2 test).
- `.claude/skills` copy differs from `.agents/skills` → checker fails (Task 2 test).
- Checker run from another cwd with a relative target path → works (Task 2 test).

---

### Task 1: Text fixes and entry-point templates

**Files:**
- Create: `templates/agents-entry.md`, `templates/claude-entry.md`
- Modify: `bootstrap.md`, `templates/local-workflow.md`, `templates/project-map.md`, `profiles/capability-workstreams.md`, `README.md`, `scripts/validate.sh`

- [ ] **Step 1:** Add to `validate.sh` required files for both templates and a `trial_rules` phrase check: `bootstrap.md` — `directory the user names`, `already present`, `templates/agents-entry.md`, `target repository \`HEAD\``, `URL or local path`; `templates/project-map.md` — `none found`; `profiles/capability-workstreams.md` — `escalation trigger`; `README.md` — `for Claude Code and Codex`; `templates/local-workflow.md` must not contain `<TASK_ARTIFACTS_PATH>`.
- [ ] **Step 2:** Run validate. Expected: failures, exit 1.
- [ ] **Step 3:** Write `templates/agents-entry.md` (title, markers, the step-6 list as fixed text, one line `` The test command is `<TEST_COMMAND>`. ``) and `templates/claude-entry.md` (title, markers, `@AGENTS.md`).
- [ ] **Step 4:** Edit `bootstrap.md`: step 1.1 (named directory first), step 4.1.1 (definition of configured), step 4 entry bullets reference the two templates, operating contract (URL or local path; commit = target `HEAD`, dirty worktree → unknowns), step 6 points to `templates/agents-entry.md` as the source of the list.
- [ ] **Step 5:** `local-workflow.md`: `` under `docs/agent/tasks/` (an active integration may override this path) ``. `project-map.md` legend: absent tooling → `unknown` with "none found". Profile security section: absent control → cross-cutting concern with its escalation trigger. README quick-start prompt: "Initialize the agent workflow for Claude Code and Codex in this repository…".
- [ ] **Step 6:** Run validate. Expected: exit 0.
- [ ] **Step 7:** Commit: "Resolve trial-run findings in bootstrap and templates".

### Task 2: Target checker

**Files:**
- Create: `scripts/check-target.sh`, `tests/check-target/run.sh` (fixture-based tests)
- Modify: `bootstrap.md` step 7 items 8–9, `scripts/validate.sh`

**Interfaces:**
- `scripts/check-target.sh <target-dir>` → exit 0 and `Target check passed: <dir>`; exit 1 with `<relative path>: <problem>` lines.

- [ ] **Step 1:** Write `tests/check-target/run.sh`: builds fixtures in a temp dir from `examples/task-tracker` copies and asserts: unchanged example → pass; `CLAUDE.md` replaced by symlink → pass; `CLAUDE.md` removed → pass; extra line inside `AGENTS.md` markers → fail; `@AGENTS.md` duplicated → fail; `.claude/skills/x/SKILL.md` differing from `.agents/skills/x/SKILL.md` → fail; placeholder `` `<X>` `` in project map → fail; run from `/` with relative path resolved beforehand → pass. Add it to `validate.sh`.
- [ ] **Step 2:** Run validate. Expected: fails (checker missing).
- [ ] **Step 3:** Implement `scripts/check-target.sh` per spec "Design".
- [ ] **Step 4:** `bootstrap.md` step 7: item 8 runs `scripts/check-target.sh <target>` from the playbook checkout and reports its output; item 9 defines the no-write pass as re-deriving facts, comparing them with the maps, and running the checker.
- [ ] **Step 5:** Run validate. Expected: the unchanged-example case fails until Task 3 regenerates the example — record that as expected; all other cases pass.
- [ ] **Step 6:** Commit: "Add target checker".

### Task 3: Example review fixes

From the example-branch review. Each code fix starts with a failing test.

**Files:**
- Modify: `examples/task-tracker/{src/tracker/api.py,src/tracker/db.py,src/tracker/cli.py,pyproject.toml,tests/*}`, `scripts/validate.sh`
- Create: `.github/workflows/validate.yml` (playbook root), `AGENTS.md` and `CLAUDE.md` (playbook root)

- [ ] **Step 1:** Tests: `Content-Length: -1` and `abc` → 400 without hanging (socket timeout 2 s); deeply nested JSON → 400; id `99999999999999999999` → 404; CLI `add ""` and `add "   "` → exit 1, nothing stored; two connections applying migrations concurrently → no error and one `schema_migrations` row.
- [ ] **Step 2:** Run tests. Expected: those fail.
- [ ] **Step 3:** API: parse `Content-Length` inside the `try`, reject negative/non-integer with 400; catch `RecursionError`; catch `OverflowError` for ids → 404; release the lock before writing the response. DB: open with `isolation_level=None`, `BEGIN IMMEDIATE`, re-read applied migrations inside the transaction, execute statements, insert the row, `COMMIT`. CLI: strip title, reject blank with stderr and exit 1.
- [ ] **Step 4:** Drop `[project.scripts]` from `pyproject.toml` (installed package cannot find `migrations/`); document `python3 -m tracker.cli`.
- [ ] **Step 5:** `validate.sh`: print the example test output on failure.
- [ ] **Step 6:** Root `.github/workflows/validate.yml` runs `bash scripts/validate.sh` on push and pull request (Python 3.9 and 3.12). Root `AGENTS.md` + `CLAUDE.md` (`@AGENTS.md`): this repository is the playbook; `examples/` contains target-repository fixtures whose instruction files apply only to work inside that example.
- [ ] **Step 7:** Run validate. Expected: exit 0 (except the checker's unchanged-example case, fixed in Task 4).
- [ ] **Step 8:** Commit: "Fix example robustness and add playbook CI".

### Task 4: Regenerate example and close findings

**Files:**
- Modify: `examples/task-tracker/{AGENTS.md,CLAUDE.md,docs/agent/workflow.md,docs/agent/project-map.md,TRIAL.md}`, `scripts/validate.sh`

- [ ] **Step 1:** Regenerate `AGENTS.md` and `CLAUDE.md` from the templates, `workflow.md` from the updated local-workflow template; apply the "none found" rule in the project map; update the playbook revision to current `main`. Map commit fields = the commit that last changed `examples/task-tracker` code (target `HEAD` equivalent). Restore the dropped capability-map template line; remove the non-template "Run from the repository root." line; correct the concurrency note (single-threaded server) and the `tracker` script entry.
- [ ] **Step 2:** Add a `Status` column to `TRIAL.md` (`fixed in <commit>`). Correct #2 (step 4.1.1 does define "configured"; the gap is a repository with no tool files) and #6 (wrong commit was recorded). Add: nested CI workflow never runs on the host; omitting skill copies skipped steps 4 and 7.6 by design.
- [ ] **Step 3:** In `validate.sh`, replace the ad-hoc example placeholder/import checks with `scripts/check-target.sh examples/task-tracker`.
- [ ] **Step 4:** Run validate. Expected: exit 0, including all checker fixture cases.
- [ ] **Step 5:** Commit: "Regenerate example from templates and close trial findings".

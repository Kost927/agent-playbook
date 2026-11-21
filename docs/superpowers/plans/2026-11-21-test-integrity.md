# Test Integrity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Detect deleted, skipped, or weakened tests mechanically and make the reviewer account for every finding.

**Architecture:** New `scripts/check-tests-diff.sh` (Bash wrapper + inline Python, like `check-target.sh`) with fixture tests in `tests/check-tests-diff/run.sh`; text rules in workflow, roles, skills, templates.

**Tech Stack:** Bash, Python 3.9+, git.

**Spec:** `docs/superpowers/specs/2026-11-21-test-integrity-design.md`

## Global Constraints

- Script never writes to the target repository; runs from the playbook checkout against `git -C <repo>`; default repo is the current directory, override with `--repo <dir>`.
- Exit codes: 0 clean, 1 findings, 2 usage error.
- `bash scripts/validate.sh` (with `set -o pipefail`) exits 0 after each task.

## Review Focus

- Renamed test file (git rename) must not count as deleted.
- A test file that gains assertions overall but loses one test definition still reports the removed definition.
- Non-test files containing `skip` must not be reported.
- `--tests-commit` that is not an ancestor of head → usage error.
- Works on Python 3.9 and in CI on Linux.

---

### Task 1: Script and fixture tests

**Files:** Create `scripts/check-tests-diff.sh`, `tests/check-tests-diff/run.sh`; modify `scripts/validate.sh`.

- [ ] **Step 1:** Write `tests/check-tests-diff/run.sh`: builds temp git repos and asserts exit code and a finding substring for: clean change (0); deleted test file (1, `deleted-test-file`); renamed test file (0); removed test definition (1, `removed-test`); added `skip` marker (1, `skip-marker`); `skip` in non-test file (0); fewer assertions (1, `fewer-assertions`); test file edited after `--tests-commit` (1, `changed-after-tests-commit`); non-ancestor `--tests-commit` (2). Add it to `validate.sh`.
- [ ] **Step 2:** Run validate. Expected: fails (script missing).
- [ ] **Step 3:** Implement the script per spec patterns using `git diff --find-renames --name-status` and per-file unified diffs (`-U0`).
- [ ] **Step 4:** Run validate. Expected: exit 0.
- [ ] **Step 5:** Commit.

### Task 2: Rules and templates

**Files:** `workflow.md`, `templates/local-workflow.md`, `roles/implementer.md`, `roles/reviewer.md`, `skills/review-task/SKILL.md`, `skills/execute-task-workflow/SKILL.md`, `templates/task.md`, `templates/review-report.md`, `README.md` (repository contents), `scripts/validate.sh`, examples' `docs/agent/workflow.md` (regenerate).

- [ ] **Step 1:** Phrase checks: `workflow.md` — `Tests commit`, `check-tests-diff.sh`; `templates/local-workflow.md` — `Tests commit`, `check-tests-diff.sh`; `templates/task.md` — `Tests commit:`; `templates/review-report.md` — `## Test integrity`; reviewer role and review skill — `check-tests-diff.sh`; implementer role — `Tests commit`.
- [ ] **Step 2:** Run validate. Expected: failures.
- [ ] **Step 3:** Edit files; regenerate both examples' `workflow.md` (keep recorded revisions and roster).
- [ ] **Step 4:** Run validate. Expected: exit 0.
- [ ] **Step 5:** Commit.

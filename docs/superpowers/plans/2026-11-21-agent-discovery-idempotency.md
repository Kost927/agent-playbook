# Agent Discovery and Idempotency Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make initialized repositories discoverable by both Claude Code and Codex, and make repeated initialization diff-free.

**Architecture:** Documentation-only. `bootstrap.md` gains concrete entry-point and skill-path rules plus a date/SHA rule; README, the initialize skill, and templates follow. `scripts/validate.sh` phrase checks are the tests.

**Tech Stack:** Markdown, Bash + inline Python 3.

**Spec:** `docs/superpowers/specs/2026-11-21-agent-discovery-idempotency-design.md`

## Global Constraints

- Codex skills: `.agents/skills/<name>/SKILL.md` (canonical). Claude Code skills: `.claude/skills/<name>/SKILL.md`, identical generated copy, only when Claude Code is configured (repository evidence or the user's request).
- `CLAUDE.md` contains an `@AGENTS.md` import inside its own managed markers; Claude-only content outside markers is preserved.
- Final report mentions Claude Code's one-time approval prompt for the `@AGENTS.md` import.
- No symlinks; no user-global locations.
- `Last verified against commit`, `Verified on`, `Last reconciled` change only when other content of the same file changes in that run.
- `bash scripts/validate.sh` exits 0 at the end of every task. Markdown links in this plan are code spans.

## Review Focus

- Existing `CLAUDE.md` with substantial manual content → import added, content not moved or deleted (Task 1 text).
- Repo with only Codex configured → no `.claude/skills/` created (Task 2 text).
- Update mode after a playbook revision bump → both skill copies refreshed and still identical (Task 2 text).
- No-write second pass on unchanged repo → dates/SHAs untouched (Task 1 text).
- Monorepo with nested `AGENTS.md` → nested `CLAUDE.md` imports its sibling `AGENTS.md`, not the root one (Task 1 text).

---

### Task 1: Entry points and idempotent dates

**Files:**
- Modify: `bootstrap.md` (operating contract line 15; step 4 lines 56–57; step 5 item 4; step 6 first paragraph; step 7 item 3; report paragraph after step 7), `templates/project-map.md`, `templates/capability-map.md`, `templates/integration-map.md`, `templates/local-workflow.md`, `scripts/validate.sh`

- [ ] **Step 1:** Add `discovery_rules` check to `validate.sh` (same pattern as `question_rules`): `bootstrap.md` must contain `@AGENTS.md`, `one-time approval`, `only when other content of the same file changes`, `sibling`; each of the four templates must contain `only when this file's facts change`.
- [ ] **Step 2:** Run `bash scripts/validate.sh`. Expected: 8 `missing discovery rule` errors, exit 1.
- [ ] **Step 3:** `bootstrap.md`:
  - operating contract: after the no-diff line add "Date and commit fields (`Last verified against commit`, `Verified on`, `Last reconciled`) change only when other content of the same file changes in that run."
  - step 4: `AGENTS.md` — "entry point read by Codex; holds the managed block"; `CLAUDE.md` — "entry point read by Claude Code; contains `@AGENTS.md` inside managed markers plus optional Claude-only content outside them". Nested instruction files: a nested `CLAUDE.md` imports its sibling `AGENTS.md`.
  - step 5 item 4: process lives in `docs/agent/workflow.md`; `CLAUDE.md` imports `AGENTS.md` rather than repeating it; if `CLAUDE.md` already has content, add the import without moving that content.
  - step 6: "The two entry points" → the `AGENTS.md` managed block (list unchanged; add "follow *Questions and checkpoints*").
  - step 7 item 3: "Check that each `CLAUDE.md` imports its sibling `AGENTS.md` with `@AGENTS.md`."
  - report paragraph: add "and, when `CLAUDE.md` was created or changed, that Claude Code asks once to approve the `@AGENTS.md` import."
- [ ] **Step 4:** In each of the four templates, under the date/SHA lines, add: "Update the date and commit only when this file's facts change." (for `local-workflow.md` place it under `Last reconciled`, inside the managed block).
- [ ] **Step 5:** Run `bash scripts/validate.sh`. Expected: exit 0.
- [ ] **Step 6:** Commit `bootstrap.md templates/ scripts/validate.sh`: "Make CLAUDE.md import AGENTS.md and keep dates idempotent".

### Task 2: Skill locations for Claude Code and Codex

**Files:**
- Modify: `bootstrap.md` step 4.1 (items 3–4, item 7, trailing paragraph), step 7 item 6; `skills/initialize-agent-workflow/SKILL.md` (Skill installation boundary paragraph); `README.md` ("What initialization creates" tree and bullets; "Project-local skills"); `scripts/validate.sh`

- [ ] **Step 1:** Extend `discovery_rules`: `bootstrap.md` must contain `.claude/skills/<skill-name>/SKILL.md`, `byte-identical`, `symlink`; `skills/initialize-agent-workflow/SKILL.md` must contain `.claude/skills/` and `byte-identical`; `README.md` must contain `.claude/skills/` and `@AGENTS.md`.
- [ ] **Step 2:** Run `bash scripts/validate.sh`. Expected: 7 `missing discovery rule` errors, exit 1.
- [ ] **Step 3:** `bootstrap.md` step 4.1: item 3 — `.agents/skills/<skill-name>/SKILL.md` is the canonical copy (Codex discovery path). Item 4 — when Claude Code is configured, write a byte-identical generated copy to `.claude/skills/<skill-name>/SKILL.md`; do not use a symlink (Windows and some git setups break them); create no other copies. Item 7 — update mode refreshes both copies. Trailing paragraph: if configuration is ambiguous, create the `.agents/skills/` copy and report whether to add the Claude copy. Step 7 item 6: add "and confirm `.claude/skills/` copies are byte-identical to `.agents/skills/`".
- [ ] **Step 4:** Initialize skill: replace the "Keep `.agents/skills/` as the canonical…" sentence with the same rule (canonical `.agents/skills/`, byte-identical `.claude/skills/` copy when Claude Code is configured, no symlinks).
- [ ] **Step 5:** README: tree adds `.agents/skills/…` and `.claude/skills/…`; bullet says `AGENTS.md` holds the managed entry point and `CLAUDE.md` imports it with `@AGENTS.md`; "Project-local skills" names both paths.
- [ ] **Step 6:** Run `bash scripts/validate.sh`. Expected: exit 0.
- [ ] **Step 7:** Commit `bootstrap.md skills/initialize-agent-workflow/SKILL.md README.md scripts/validate.sh`: "Install skills for both Codex and Claude Code".

# Context and Models Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add context-hygiene, subagent, model-tier, and cross-vendor review rules to the playbook and to initialized repositories.

**Architecture:** Canonical section in `workflow.md`; condensed managed copy with a model roster table in `templates/local-workflow.md`; one-line references elsewhere; examples regenerated; `validate.sh` phrase checks.

**Tech Stack:** Markdown, Bash + inline Python.

**Spec:** `docs/superpowers/specs/2026-11-21-context-and-models-design.md`

## Global Constraints

- No concrete model names in playbook files.
- Roster Model cells are `` `<model or session default>` `` placeholders in the template; examples use `` `session default` ``.
- `bash scripts/validate.sh` (with `set -o pipefail` when piping) exits 0 after each task.

## Review Focus

- Template roster table must stay a valid GFM table with placeholders (no `|` inside cells).
- `check-target.sh` must still pass both examples after regeneration.
- Rule wording in the condensed copy must not contradict the canonical section.

---

### Task 1: Canonical rules, local copy, examples

**Files:** `workflow.md`, `templates/local-workflow.md`, `bootstrap.md`, `examples/*/docs/agent/workflow.md`, `scripts/validate.sh`

- [ ] **Step 1:** Add `context_rules` phrase checks: `workflow.md` — `## Context and models`, `artifacts on disk`, `fresh session`, `context isolation`, `implementer's narrative`, `deep`, `different model family`, `session default`; `templates/local-workflow.md` — `Context and models`, `fresh session`, `artifacts on disk`, `different model family`, `| Role | Tier | Model |`; `bootstrap.md` — `model roster`.
- [ ] **Step 2:** Run validate. Expected: failures.
- [ ] **Step 3:** Write the section, the condensed copy with roster, and the bootstrap sentence.
- [ ] **Step 4:** Regenerate both examples' `docs/agent/workflow.md` from the template (same URL/revision/date substitutions as before; roster `session default`).
- [ ] **Step 5:** Run validate. Expected: exit 0.
- [ ] **Step 6:** Commit.

### Task 2: Templates, roles, skills

**Files:** `templates/review-report.md`, `templates/handoff.md`, `roles/reviewer.md`, `roles/implementer.md`, `skills/review-task/SKILL.md`, `skills/execute-task-workflow/SKILL.md`, `scripts/validate.sh`

- [ ] **Step 1:** Phrase checks: review-report — `Implementer: ` and `Reviewer: `; handoff — `Start a fresh session`; reviewer role and review skill — `Context and models`; implementer role and execute skill — `Context and models`.
- [ ] **Step 2:** Run validate. Expected: failures.
- [ ] **Step 3:** Edit the six files.
- [ ] **Step 4:** Run validate. Expected: exit 0.
- [ ] **Step 5:** Commit.

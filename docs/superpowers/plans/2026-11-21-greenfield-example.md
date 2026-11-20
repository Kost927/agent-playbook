# Greenfield Example Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a greenfield example showing a good interview and the resulting bootstrap outputs.

**Architecture:** Documentation-only fixture in `examples/greenfield-notes/`, checked by `scripts/check-target.sh` and an extra "no verified entries" check in `validate.sh`.

**Tech Stack:** Markdown, Bash.

**Spec:** `docs/superpowers/specs/2026-11-21-greenfield-example-design.md`

## Global Constraints

- Follow `greenfield.md` and the templates exactly; entry points and workflow from templates.
- `INTERVIEW.md` states it is synthetic.
- No map entry with status `verified`; ADR `Status: proposed`; scaffolding card `Status: blocked`.
- Markdown links in this plan are code spans.

## Review Focus

- Interview re-asks something the README states → violates `greenfield.md` (Task 1 review).
- Product brief contains an answer the human never gave → must be marked as agent proposal (Task 1).
- Scaffolding card acceptance criteria match `greenfield.md` minimum list (Task 1).
- Checker treats the example as Claude-configured → `CLAUDE.md` present (Task 1).
- `validate.sh` "no verified" check ignores the legend line (Task 1).

---

### Task 1: Greenfield example

**Files:**
- Create: `examples/greenfield-notes/{README.md,INTERVIEW.md,AGENTS.md,CLAUDE.md,docs/agent/workflow.md,docs/agent/product-brief.md,docs/agent/project-map.md,docs/agent/capability-map.md,docs/adr/0001-stack.md,docs/agent/tasks/001-scaffold.md}`
- Modify: `scripts/validate.sh`, `README.md` (repository contents), `greenfield.md` (link to the example)

- [ ] **Step 1:** `validate.sh`: run `check-target.sh --no-skills --agents claude,codex examples/greenfield-notes`; require `INTERVIEW.md`; fail if any table row in the two maps ends with `| verified |` or `| verified | ... |` (match `` \| verified \| `` in table rows, not the legend).
- [ ] **Step 2:** Run validate. Expected: fail (directory missing).
- [ ] **Step 3:** Write the human `README.md`, then `INTERVIEW.md`, then the outputs from templates.
- [ ] **Step 4:** Link the example from `greenfield.md` ("See `examples/greenfield-notes/INTERVIEW.md`") and from README repository contents.
- [ ] **Step 5:** Run validate. Expected: exit 0.
- [ ] **Step 6:** Commit: "Add greenfield interview example".

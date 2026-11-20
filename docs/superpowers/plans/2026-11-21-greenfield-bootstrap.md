# Greenfield Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let the playbook initialize empty repositories through an interview that records product intent and a human-chosen stack, with scaffolding as the first regular task.

**Architecture:** Documentation-only change. A new `greenfield.md` procedure is linked from `bootstrap.md` step 1; two new templates (`product-brief.md`, `adr.md`) hold its output; existing maps gain a `planned | verified` status. `scripts/validate.sh` is the test harness: each task first adds a check that fails, then makes it pass.

**Tech Stack:** Markdown, Bash + inline Python 3 (`scripts/validate.sh`), static HTML/JS (`docs/flow.html`).

**Spec:** `docs/superpowers/specs/2026-11-21-greenfield-bootstrap-design.md`

## Before starting

The working tree already holds uncommitted work (`README.md`, `bootstrap.md`, `scripts/validate.sh`, `skills/`). Commit it separately first so task commits contain only plan changes. Add a `.gitignore` with `.DS_Store` in that commit.

## Global Constraints

- Bootstrap must not write product code or scaffold the project, in greenfield mode too.
- Greenfield = no build/package manifests and no source files; only `README`, `LICENSE`, `.gitignore`, agent/editor configuration may exist. Anything else → existing-repository mode.
- Interview: one question per message, recommendation when reasonable, never ask what the request/README/earlier answers settle.
- Interview topics: what and for whom; success; non-goals; constraints (team skills, hosting, budget, compliance, organization standards); first milestone.
- Stack: 2–3 options with trade-offs tied to stated constraints + a recommendation; the human chooses.
- Output paths: `docs/agent/product-brief.md`, `docs/adr/0001-stack.md`, first task card for scaffolding.
- Map entries carry status `planned` or `verified`; planned facts are never presented as verified.
- Generated docs in English, vendor-neutral, no stack catalog.
- `bash scripts/validate.sh` must exit 0 at the end of every task.

## Review Focus

- A repo with only `README.md` containing a product description → interview must skip questions the README answers (Task 2 wording check).
- A repo with a manifest but no source (e.g. only `package.json`) → existing-repository mode, not greenfield (Task 2 detection wording names manifests explicitly).
- Human answers "you decide" for the stack → agent still records the recommendation as an ADR with status `proposed` until confirmed (Task 2).
- Re-running bootstrap on a greenfield repo after the interview → must not re-interview; it reads `product-brief.md` (Task 2 check).
- Update mode after scaffolding with a planned item that did not materialize → recorded as a discrepancy, not silently deleted (Task 3).

---

### Task 1: Templates for product brief and ADR

**Files:**
- Create: `templates/product-brief.md`, `templates/adr.md`
- Modify: `scripts/validate.sh` (`required_files`), `workflow.md` (step 4 ADR sentence links `templates/adr.md`)

**Interfaces:**
- Produces: `templates/product-brief.md` with headings `## Product and users`, `## Success`, `## Non-goals`, `## Constraints`, `## First milestone`, `## Open questions`; header fields `Status:`, `Interviewed on:`.
- Produces: `templates/adr.md` with header `# ADR-<NNNN>: <TITLE>`, `Status: <proposed | accepted | superseded>`, headings `## Context`, `## Options considered`, `## Decision`, `## Consequences`.

- [ ] **Step 1:** Add `templates/product-brief.md` and `templates/adr.md` to `required_files` in `scripts/validate.sh`.
- [ ] **Step 2:** Run `bash scripts/validate.sh`. Expected: `Missing required file: templates/product-brief.md`, exit 1.
- [ ] **Step 3:** Create both templates with the headings above, placeholders in the existing `` `<...>` `` style. `## Options considered` is a table `| Option | Trade-offs | Fit with constraints |`.
- [ ] **Step 4:** In `workflow.md` step 4, change "Use an ADR for important decisions…" to link [`templates/adr.md`](templates/adr.md).
- [ ] **Step 5:** Run `bash scripts/validate.sh`. Expected: exit 0.
- [ ] **Step 6:** Commit: `git add templates/product-brief.md templates/adr.md scripts/validate.sh workflow.md && git commit -m "Add product brief and ADR templates"`.

### Task 2: Greenfield procedure and bootstrap detection

**Files:**
- Create: `greenfield.md`
- Modify: `bootstrap.md` (step 1 detection, step 4 artifact list, "Do not create empty task artifacts" exception), `scripts/validate.sh`

**Interfaces:**
- Consumes: `templates/product-brief.md`, `templates/adr.md`, `templates/task.md`.
- Produces: `greenfield.md` sections `## When to use`, `## Interview`, `## Stack decision`, `## Outputs`, `## After scaffolding`.

- [ ] **Step 1:** Add `greenfield.md` to `required_files`, and a Python check: `bootstrap.md` must contain the substring `(greenfield.md)`; error text `bootstrap.md: must link greenfield.md`.
- [ ] **Step 2:** Run `bash scripts/validate.sh`. Expected: `Missing required file: greenfield.md`, exit 1.
- [ ] **Step 3:** Write `greenfield.md`:
  - `When to use`: the greenfield definition from Global Constraints verbatim; a manifest without source is existing mode; if `docs/agent/product-brief.md` already exists, do not re-interview — read it and continue.
  - `Interview`: the rules and topics from Global Constraints; first read the request and README and list what is already answered; stop when the brief can be written; leftovers go to `## Open questions`.
  - `Stack decision`: 2–3 options, trade-offs tied to constraints, recommendation, human chooses. If the human defers ("you decide"), write the ADR with `Status: proposed` and ask for confirmation in the final report.
  - `Outputs`: `docs/agent/product-brief.md`, `docs/adr/0001-stack.md`, maps with `planned` entries, a scaffolding task card (Standard route, ACs: project builds, a trivial test runs, lint/format runs, commands match the ADR), plus the normal entry points/workflow/skills.
  - `After scaffolding`: run bootstrap update mode; verify each `planned` entry and flip to `verified`; planned entries that did not materialize stay and are listed as discrepancies.
- [ ] **Step 4:** In `bootstrap.md` step 1 add item: "If the repository is greenfield as defined in [`greenfield.md`](greenfield.md), follow that procedure, then continue from step 4." In step 4 list `product-brief.md` and `docs/adr/0001-stack.md` as greenfield-only outputs, and amend "Do not create empty task artifacts" with the greenfield scaffolding-task exception. The existing no-product-code rule in "Operating contract" already covers greenfield; leave it unchanged.
- [ ] **Step 5:** Run `bash scripts/validate.sh`. Expected: exit 0.
- [ ] **Step 6:** Commit: `git add greenfield.md bootstrap.md scripts/validate.sh && git commit -m "Add greenfield bootstrap procedure"`.

### Task 3: Planned/verified status in maps

**Files:**
- Modify: `templates/project-map.md`, `templates/capability-map.md`, `bootstrap.md` (Update mode list, step 6 last paragraph), `scripts/validate.sh`

**Interfaces:**
- Produces: a `Status` column (`planned | verified`) in every fact table of both map templates; a one-line legend under each title: "Status: `verified` = found in repository or executed; `planned` = decided but not yet present (greenfield)."

- [ ] **Step 1:** Add a Python check: both map templates must contain `planned | verified`; error `<file>: missing planned/verified status`.
- [ ] **Step 2:** Run `bash scripts/validate.sh`. Expected: two status errors, exit 1.
- [ ] **Step 3:** Add the legend and `Status` column to the tables in both templates (Verified commands table: replace nothing, add column before `Last result`).
- [ ] **Step 4:** In `bootstrap.md` Update mode add step: "Re-check every `planned` entry; mark it `verified` with evidence, or keep it `planned` and report it as a discrepancy." In step 6 add: "Never present a `planned` entry as verified."
- [ ] **Step 5:** Run `bash scripts/validate.sh`. Expected: exit 0.
- [ ] **Step 6:** Commit: `git add templates/project-map.md templates/capability-map.md bootstrap.md scripts/validate.sh && git commit -m "Add planned/verified status to project maps"`.

### Task 4: Skill, README, and flow map

**Files:**
- Modify: `skills/initialize-agent-workflow/SKILL.md`, `README.md`, `docs/flow.html`

**Interfaces:**
- Consumes: `greenfield.md` section names from Task 2.

- [ ] **Step 1:** Skill: description adds "including new, empty repositories (interview and stack decision)"; `Source` paragraph adds "Read `greenfield.md` when the repository is greenfield."; `Required outcomes` adds the greenfield outputs.
- [ ] **Step 2:** README: add `## New projects` after "Quick start" — 4–6 lines: empty repo triggers an interview, stack is your decision, outputs, scaffolding is the first task, update mode verifies. Add `greenfield.md` to "Repository contents".
- [ ] **Step 3:** `docs/flow.html`: add `<option value="greenfield">New, empty repository</option>` first in `#scenario`, and a `greenfield` entry in `scenarios` with title "New, empty repository", description stating interview → product brief → stack ADR → scaffolding task → update mode verifies, workstreams `["Interview", "Product brief", "Stack ADR", "Scaffolding task", "Planned → verified"]`.
- [ ] **Step 4:** Run `bash scripts/validate.sh` (exit 0) and open `docs/flow.html` in a browser; selecting the new scenario shows its title, description, and five chips with no console errors.
- [ ] **Step 5:** Commit: `git add skills/initialize-agent-workflow/SKILL.md README.md docs/flow.html && git commit -m "Document greenfield mode in skill, README, and flow map"`.

# Questions and Checkpoints Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give agents one canonical rule set for when and how to ask questions, with a route-based checkpoint before Standard/Full implementation.

**Architecture:** Documentation-only. A new `## Questions and checkpoints` section in `workflow.md` is the single source; other files reference it in one line. `scripts/validate.sh` is the test harness (add a failing phrase check, then make it pass).

**Tech Stack:** Markdown, Bash + inline Python 3.

**Spec:** `docs/superpowers/specs/2026-11-21-questions-checkpoints-design.md`

## Global Constraints

- The rules live only in `workflow.md`; referencing files must not copy them.
- Direct/Fast: no stop unless blocked; assumptions listed in the final report.
- Standard/Full: one checkpoint message before code (route + reason, affected workstreams, acceptance criteria, assumptions, open questions with recommendations); wait for approval; approval covers only what was shown; scope change → new checkpoint.
- Question format: recommendation first, concrete options with trade-offs, numbered questions, dependent questions one at a time.
- No changes to `docs/flow.html` or `roles/reviewer.md`.
- `bash scripts/validate.sh` exits 0 at the end of every task.
- Markdown links in this plan are written as code spans (the validator checks links in every `.md`).

## Review Focus

- Mid-task escalation from Fast to Standard → agent must stop for a checkpoint before continuing to code (Task 1 text).
- Human approves checkpoint, then agent discovers an extra affected unit → new checkpoint, not silent expansion (Task 1 text).
- Question answerable from `project-map.md` → agent looks it up instead of asking (Task 1 text).
- Agent reads only `execute-task-workflow` skill → still learns a checkpoint exists and where the rules are (Task 2 text).
- Validator phrase checks pass for wording that drops a rule → each rule has its own phrase (Task 1 check list).

---

### Task 1: Canonical section in workflow.md and specification template

**Files:**
- Modify: `workflow.md` (new section after "Choose a route"; Discover step bullet), `templates/specification.md`, `scripts/validate.sh`

**Interfaces:**
- Produces: heading `## Questions and checkpoints` in `workflow.md` (anchor `#questions-and-checkpoints`); subheadings `### When to ask`, `### When not to ask`, `### How to ask`, `### Checkpoints by route`.
- Produces: `## Assumptions` heading in `templates/specification.md`.

- [ ] **Step 1:** Add to `scripts/validate.sh` a `question_rules` dict check (same pattern as `greenfield_rules`): `workflow.md` must contain `## Questions and checkpoints`, `look first`, `Lead with your recommendation`, `one at a time`, `list assumptions in the final report`, `wait for approval`, `new checkpoint`, `Decisions table`; `templates/specification.md` must contain `## Assumptions`. Error: `<file>: missing question rule: <phrase>`.
- [ ] **Step 2:** Run `bash scripts/validate.sh`. Expected: 9 `missing question rule` errors, exit 1.
- [ ] **Step 3:** Write the section with the four subheadings, content per spec "Design", containing every phrase above. Replace the Discover bullet "Ask only questions whose answers change…" with "Ask questions according to [Questions and checkpoints](#questions-and-checkpoints)."
- [ ] **Step 4:** Add `## Assumptions` (between "Contracts and invariants" and "Risks and rollout") to `templates/specification.md` with placeholder `` - `<assumption the agent made, and how it can be confirmed>` ``.
- [ ] **Step 5:** Run `bash scripts/validate.sh`. Expected: exit 0.
- [ ] **Step 6:** Commit `workflow.md templates/specification.md scripts/validate.sh`: "Add questions and checkpoints rules".

### Task 2: References from local workflow, skill, and implementer role

**Files:**
- Modify: `templates/local-workflow.md`, `skills/execute-task-workflow/SKILL.md`, `roles/implementer.md`, `scripts/validate.sh`

**Interfaces:**
- Consumes: `workflow.md#questions-and-checkpoints` from Task 1.

- [ ] **Step 1:** Extend `question_rules`: each of the three files must contain `Questions and checkpoints` and `checkpoint`.
- [ ] **Step 2:** Run `bash scripts/validate.sh`. Expected: `missing question rule` errors for the three files, exit 1.
- [ ] **Step 3:** Add one line to each:
  - `templates/local-workflow.md` Task process, new step after route selection: "Ask questions and run the Standard/Full checkpoint as defined in the playbook's *Questions and checkpoints*; wait for approval before code."
  - `skills/execute-task-workflow/SKILL.md` Perform the task: replace "Resolve behavior-changing ambiguity before implementation." with "Ask questions per the playbook's *Questions and checkpoints*; on Standard/Full, send one checkpoint message and wait for approval before code."
  - `roles/implementer.md` Procedure step 2: append "On Standard/Full, confirm the checkpoint was approved (see `workflow.md` *Questions and checkpoints*)."
- [ ] **Step 4:** Run `bash scripts/validate.sh`. Expected: exit 0.
- [ ] **Step 5:** Commit the four files: "Reference questions and checkpoints from local workflow, skill, and role".

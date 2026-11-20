# Greenfield Bootstrap — Design

Date: 2026-11-21
Status: approved

## Intent

The playbook should work on brand-new (empty) repositories, not only existing ones. Today `bootstrap.md` derives every fact from repository evidence, so an empty repository yields empty maps and the agent asks nothing about the product. In a new project the agent should interview the human, capture product intent and the stack decision, and hand off to a normal first task for scaffolding.

## Goals

- Detect a greenfield repository during bootstrap and switch to a greenfield mode.
- Run a structured interview: one question at a time, with a recommendation when possible, skipping anything already answered by the request or README.
- Propose 2–3 stack options with trade-offs and a recommendation; the human decides.
- Persist the outcome as durable artifacts that later agents read.
- Make scaffolding the first regular task (acceptance criteria, review), not part of bootstrap.
- Convert planned facts into verified facts after scaffolding via update mode.

## Non-goals

- Bootstrap does not write product code or scaffold the project.
- Partially started repositories (some code present) stay in the existing-repository mode.
- No stack catalog or framework-specific guidance in the playbook.

## Anti-goals

- An interview that asks a long questionnaire upfront or asks questions the request already answers.
- The agent silently choosing a stack.
- Planned facts presented as verified.

## Approaches considered

| Option | Trade-off | Decision |
| --- | --- | --- |
| A. Minimal: create workflow files, mark maps "unknown" | Simplest; no product understanding, no questions | Rejected |
| B. Interview → record decisions; scaffolding is the first task | Captures intent and asks the right questions; keeps bootstrap safe | **Chosen** |
| C. Interview + scaffolding inside bootstrap | Fastest result; breaks bootstrap's "no product code" contract and skips review | Rejected |

## Design

### Detection (bootstrap step 1)

Greenfield when the repository has no build/package manifests and no source files; only files such as `README`, `LICENSE`, `.gitignore`, and agent/editor configuration may be present. Otherwise use the existing procedure.

### `greenfield.md` (new, linked from `bootstrap.md`)

Interview rules:

- One question per message; offer a recommended answer when one is reasonable.
- Never ask what the request, README, or earlier answers already settle.
- Stop when the topics below are answered well enough to write the brief; record the rest as open questions.

Topics: what is being built and for whom; what success looks like; non-goals; constraints (team skills, hosting, budget, compliance, organization standards); the first milestone.

Stack decision: present 2–3 options with trade-offs tied to the stated constraints and a recommendation; the human chooses.

### Artifacts

- `docs/agent/product-brief.md` from new `templates/product-brief.md`: interview results, goals, non-goals, constraints, first milestone, open questions.
- `docs/adr/0001-stack.md` from new `templates/adr.md` (generic ADR template, also usable by `workflow.md`).
- `project-map.md` and `capability-map.md`: every entry carries a status `planned | verified`; greenfield fills them as `planned`.
- First task card from `templates/task.md`: scaffolding with acceptance criteria. Explicit exception to "no task artifacts during initialization".
- Entry points, local workflow, and project-local skills as in the existing procedure.

### Transition

After the scaffolding task, run bootstrap in update mode: verify planned entries against the real code and flip them to `verified`, recording discrepancies.

### Other updates

- `skills/initialize-agent-workflow/SKILL.md`: description and outcomes mention new projects.
- `README.md`: short "New projects" section.
- `scripts/validate.sh`: add new required files.
- `docs/flow.html`: add the greenfield branch.

## Left to the builder

- Exact wording of interview prompts and the template fields.
- Where the `planned | verified` marker sits in each map table (column vs. inline tag).
- Visual layout of the greenfield branch in `flow.html`.

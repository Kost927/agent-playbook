# Greenfield Example — Design

Date: 2026-11-21
Status: approved

## Intent

`greenfield.md` describes the interview but no example shows what a good one looks like. Agents learn question style from examples: one question at a time, a recommendation, skipping what the README answers, and stopping at the right point.

## Goals

- `examples/greenfield-notes/`: the state of an empty repository right after greenfield bootstrap.
- `INTERVIEW.md`: a synthetic interview following `greenfield.md`, with a short note per question explaining why the agent asked it (or skipped a topic).
- Outputs: `AGENTS.md`, `CLAUDE.md`, `docs/agent/{workflow,product-brief,project-map,capability-map}.md`, `docs/adr/0001-stack.md` (`proposed`, because the human deferred), `docs/agent/tasks/001-scaffold.md` (`blocked` until the ADR is accepted).
- `validate.sh`: `check-target.sh` passes on the example; no map entry is `verified`.

## Non-goals

- Scaffolding and the planned → verified transition.
- Workflow skill copies (omitted as in `task-tracker`).

## Anti-goals

- An interview that asks what the README already says, or asks everything at once.
- Presenting the synthetic interview as real.

## Design

- Product: a small notes service for one team. The human's `README.md` states the idea and the users; the interview must not re-ask those.
- Interview flow: success → non-goals → constraints (team skills, hosting, budget, compliance, organization standards) → first milestone → stack options (2–3 with trade-offs and a recommendation) → human says "you decide" → ADR `proposed`.
- Each turn: agent message, human reply, and an italic "Why" note.
- `INTERVIEW.md` opens with a line stating it is synthetic and written by the playbook authors.
- Maps: decided facts `planned`, undecided `unknown`; test command in `AGENTS.md` is the planned one from the ADR.
- Example `README.md` keeps the human's original text and adds a short "Agent workflow files" section.

## Left to the builder

- Exact product details and dialogue wording.

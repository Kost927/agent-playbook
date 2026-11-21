# Greenfield Initialization

Use this procedure from [`bootstrap.md`](bootstrap.md) when the target repository is new. In an existing codebase the facts come from the repository; in a new one they come from the human. The agent's job is to ask the questions that shape the product, help the human choose a stack, and record the answers so every later agent starts from the same decisions.

Bootstrap still does not write product code or scaffold the project. Scaffolding is the first regular task.

## When to use

The repository is greenfield when it has no build/package manifests and no source files; only `README`, `LICENSE`, `.gitignore`, and agent/editor configuration may be present. Files created by this playbook (`AGENTS.md`, `CLAUDE.md`, `docs/agent/`, `docs/adr/`, project-local skills) do not count against greenfield, so an interrupted initialization can resume.

- A manifest without source code (for example only `package.json` or `pyproject.toml`) means a stack is already chosen: use the existing-repository procedure and ask only about facts it cannot discover.
- If `docs/agent/product-brief.md` already exists, do not interview again. Read it, ask only its open questions that block the next step, and continue.

## Interview

For a worked example of the style below, see [`examples/greenfield-notes/INTERVIEW.md`](examples/greenfield-notes/INTERVIEW.md).

Before the first question, read the initial request and any `README` and list what they already answer. Never ask what the request, `README`, or earlier answers settle.

Rules:

- Ask one question per message.
- When a reasonable answer exists, offer it as a recommendation the human can accept or correct.
- Prefer open questions until the purpose is clear; offer concrete options once the human has described what they want.
- Explain briefly why you ask when the reason is not obvious: what the answer changes.
- Stop when the brief can be written. Record anything still unsettled under `## Open questions` instead of extending the interview.

Topics to cover, in roughly this order:

1. What is being built and for whom.
2. What success looks like for those users.
3. Non-goals: what is explicitly out of scope.
4. Constraints: team skills, hosting and runtime, budget, compliance and data, organization standards.
5. The first milestone: the smallest result that proves the direction.

## Stack decision

After the interview, present 2–3 stack options. For each, give the trade-offs tied to the stated constraints (team skills, hosting, budget, compliance, organization standards), then recommend one and say why. The human chooses.

If an organization standard mandates a stack, record it as the decision and list only the open choices within it.

If the human defers ("you decide"), write the ADR with `Status: proposed`, record your recommendation as the decision, and ask for confirmation in the final report. Do not treat a deferred decision as accepted.

## Outputs

Create, in addition to the normal entry points, local workflow, and project-local skills from [`bootstrap.md`](bootstrap.md):

- `docs/agent/product-brief.md` from [`templates/product-brief.md`](templates/product-brief.md), with `Status: draft` until the human confirms it in reply to the final report; then `accepted`.
- The stack ADR from [`templates/adr.md`](templates/adr.md): `docs/adr/0001-stack.md` by default, or the next number in the repository's existing ADR location. Every later reference (product brief, scaffolding task, maps) uses that actual path.
- `docs/agent/project-map.md` and `docs/agent/capability-map.md` with every decided fact marked `planned`. Undecided facts are marked `unknown`.
- A scaffolding task card from [`templates/task.md`](templates/task.md) on the Standard route, stored at the workflow's task-artifact path (default `docs/agent/tasks/` when no integration owns task artifacts). It depends on the stack ADR being accepted; while that ADR is `proposed`, the card's status is `blocked`. Its acceptance criteria at minimum: the project builds; a trivial test runs and passes; lint/format checks run; the commands match the stack ADR; bootstrap update mode has been run and every `planned` entry is `verified` or listed as a discrepancy.

The final report lists the interview answers that were recorded, the stack decision and its status, open questions, and the scaffolding task as the next action.

## After scaffolding

As the last step of the scaffolding task, run bootstrap in update mode:

1. Check every `planned` entry against the repository.
2. Mark it `verified` with evidence when it exists and works as planned.
3. If it did not materialize or differs, keep it `planned` or correct it, and list it as a discrepancy in the update report. Do not silently delete it.
4. Fill in facts that only became discoverable once code existed.

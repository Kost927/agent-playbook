# Trial-Run Fixes — Design

Date: 2026-11-21
Status: approved

## Intent

The bootstrap trial run (`examples/task-tracker/TRIAL.md`) found nine places where `bootstrap.md` is unclear or relies on the agent's discretion. Fix them so two runs produce the same result and the no-diff rule can be checked mechanically.

## Goals

1. Target root: the directory the user names; `git rev-parse --show-toplevel` only when none is named; record a nested target.
2. "Configured agent": tool files already present (`.claude/`, `CLAUDE.md`, `.codex/`, `AGENTS.md`) or the agent named in the request. README quick-start prompt names the agents.
3. Entry-point templates `templates/agents-entry.md` and `templates/claude-entry.md`: fixed managed-block text; the only repository-specific value is the test command.
4. `templates/local-workflow.md`: default task path `docs/agent/tasks/` written directly; integrations override it.
5. Absent tooling: `unknown` with "none found" as evidence.
6. Commit fields: target repository `HEAD` at verification; dirty worktree noted under unknowns.
7. Absent controls (for example no authentication): a cross-cutting concern with its escalation trigger (`profiles/capability-workstreams.md`).
8. `scripts/check-target.sh <target-dir>`: mechanical check of an initialized repository, run at the end of bootstrap and by `validate.sh` on the example.
9. Playbook source: URL or local path, plus commit SHA or tag.

Also: regenerate the example from the new templates; add a status column to `TRIAL.md`; fold in findings from the pending review of the example branch.

## Non-goals

- A full re-run of discovery logic by the checker (it checks structure, not judgment).
- Greenfield-specific checks beyond what applies to every initialized repository.

## Anti-goals

- A checker that passes while generated managed blocks drift from templates.
- Placeholder-free but false facts (the checker cannot judge these; the review still does).

## Approaches considered (item 8)

| Option | Trade-off | Decision |
| --- | --- | --- |
| Checker script | Mechanical, reusable on the example; must be fetched with the playbook | **Chosen** |
| Checklist text only | Simple; still relies on the agent's honesty | Rejected |

## Design: `scripts/check-target.sh`

Usage: `scripts/check-target.sh <target-dir>`; exits non-zero with one line per problem. Checks:

- every `AGENTS.md` that contains `agent-playbook` markers: its managed block matches `templates/agents-entry.md`, where any `` `<...>` `` placeholder in the template matches any non-empty code span;
- each such `AGENTS.md` has a sibling `CLAUDE.md` that is a symlink to it or contains exactly one line `@AGENTS.md` (only when a `CLAUDE.md` exists anywhere in the target, i.e. Claude Code is configured);
- `docs/agent/workflow.md` managed block matches `templates/local-workflow.md` with the same placeholder rule;
- `docs/agent/project-map.md` and `capability-map.md` exist;
- no `` `< `` placeholders in `AGENTS.md`, `CLAUDE.md`, `docs/agent/*.md`;
- relative Markdown links in those files resolve;
- every `.claude/skills/<name>/SKILL.md` is byte-identical to `.agents/skills/<name>/SKILL.md`.

`bootstrap.md` step 7 runs it (from the playbook checkout) and reports its output; step 9 ("repeat without writing") is defined as: re-derive facts, compare with the maps, and run the checker.

## Left to the builder

- Exact wording of the entry-point templates.
- Implementation language inside the script (Bash wrapper with inline Python, like `validate.sh`).

# Bootstrap Trial Run

Date: 2026-11-21
Playbook revision: `1bfc74bf6a7aca263e476507c58dca9830236c5f`
Procedure: `bootstrap.md` followed literally against this directory as the target repository, by an agent with no other instructions.

These findings are inputs for playbook fixes. They are intentionally not fixed in the run that produced them.

| # | Step | Issue | What the agent did | Suggested fix |
| --- | --- | --- | --- | --- |
| 1 | 1.1 | `git rev-parse --show-toplevel` returns the enclosing repository when the target is a nested directory (this example, or a package inside a monorepo the user points at). | Treated `examples/task-tracker/` as the root because the request named it. | Use the directory the user names; use `git rev-parse` only when none is named, and record when the target is nested. |
| 2 | 4, 4.1 | `CLAUDE.md` is listed under "at minimum", but `.claude/skills/` copies depend on Claude Code being "configured", which is undefined for a repository with no `.claude/`, `CLAUDE.md`, or `AGENTS.md`. | Created `CLAUDE.md`; skill copies are omitted in this example by design. | Define "configured": existing tool files or the user's request. Make the quick-start prompt name the agents in use. |
| 3 | 6 | There is no template for `AGENTS.md` or `CLAUDE.md`; the agent writes the managed block from a bullet list, so wording varies between runs and threatens the no-diff rule. | Wrote the block from the step 6 list. | Add an entry-point template with fixed managed-block text and one repository-specific line for the test command. |
| 4 | 4 | `templates/local-workflow.md` has `<TASK_ARTIFACTS_PATH>` followed by "(default … when no integration owns task artifacts)"; after filling, it is unclear whether the parenthetical stays. | Replaced both with `docs/agent/tasks/`. | Put the default directly in the template and tell integrations to override it. |
| 5 | 6 | The map `Status` legend covers `planned/verified/unknown` but not a tool category that does not exist (no linter, no build). | Used `unknown` with "unavailable" / "no configuration found". | Say explicitly: absent tooling is `unknown` with "none found" as evidence. |
| 6 | Operating contract | "Last verified against commit" does not say which commit when the worktree is dirty, or whether it is the target or playbook commit. | Recorded the target `HEAD` (here identical to the playbook commit). | State: target repository `HEAD` at verification time; note a dirty worktree in unknowns. |
| 7 | 3 | A service with no authentication: unclear whether the security workstream is activated at repository level or only when a task touches trust boundaries. | Recorded security as a cross-cutting note with an escalation trigger. | In `profiles/capability-workstreams.md`, say that an absent control is recorded as a cross-cutting concern with its escalation trigger. |
| 8 | 7.9 | "Repeat the initialization logic without writing" has no concrete method; it relies on the agent re-reasoning the same way. | Re-read the generated files against the templates and evidence; no changes proposed. | Give a concrete check, for example regenerate into a temporary directory and diff, or list the fields to compare. |
| 9 | Operating contract | "Record the exact playbook URL and revision" assumes a remote URL; a run from a local checkout has a path and a SHA. | Used the URL from the playbook README with the local commit SHA. | Allow "URL or local path" plus commit SHA or tag. |

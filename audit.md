# AI Setup Audit

Use this procedure from [`bootstrap.md`](bootstrap.md) before onboarding. Many repositories already have AI setup: instruction files for several tools, skills, hooks, MCP servers, and methodology plugins, some of it in the owner's user-level configuration. Old setup can contradict the playbook, skills can compete for the same situation, and the agent then follows the wrong instruction. The audit finds these conflicts, the owner decides each one, and the decisions are recorded so later runs stay quiet.

## When to run

- Every initialization, including greenfield: run it before the interview, because an empty repository can still have agent configuration and user-level setup. Report in the onboarding message that follows the interview.
- Update mode: rerun it and report only findings that are not already decided.

## Permission for user-level setup

User-level setup (`~/.claude`, `~/.codex`, `~/.cursor`, `~/.agents`) belongs to the owner, not the repository.

1. If the request contains permission, for example "You may read my user-level AI setup (names and descriptions only) for the audit.", use `--global`.
2. Otherwise, if `docs/agent/integrations.md` records `User-level audit: allowed` or `declined`, follow it.
3. Otherwise, ask one yes/no question at the very start of initialization, before discovery: "May I read the names and descriptions of your user-level skills, plugins, and MCP servers (`~/.claude`, `~/.codex`, `~/.cursor`, `~/.agents`) to find conflicts? Nothing is copied into the repository except the names of items you make decisions about."
4. In a non-interactive run, or without a yes, audit the repository only and say so in the report.

Record the answer as `User-level audit: allowed (owner, <YYYY-MM-DD>)` or `declined (owner, <YYYY-MM-DD>)`. A permission line in a later request overrides a recorded `declined`.

## Run the script

Run the playbook's `scripts/audit-ai-setup.sh <target-dir>`, adding `--global` only when allowed. The script is read-only. Each line is `<level>\t<kind>\t<location>\t<detail>`; it exits 1 when any warning is left.

| Kind | Level | Meaning |
| --- | --- | --- |
| `skill-duplicate` | warning | The same skill name in several locations with different content |
| `skill-shadow` | warning | A user-level skill with the same name as a repository skill and different content |
| `skill-mirror` | info | Identical copies, or the playbook's own skill at user level: the intended layout |
| `instruction-sources` | info | An instruction file for some tool |
| `claude-import-missing` | warning | `CLAUDE.md` next to `AGENTS.md` without importing it |
| `agent-docs-ignored` | warning | Git would ignore `docs/agent/`, so the shared maps could never be committed; recommend re-including it (for example `docs/*` then `!docs/agent/` when `docs/` itself is ignored) |
| `broken-reference` | warning | A relative link in an instruction file or skill that points nowhere |
| `mcp-duplicate` | warning or info | The same MCP server in several configs, with different (warning) or identical (info) definitions |
| `mcp-literal-secret` | warning | A secret-like MCP setting holding a literal value instead of an environment-variable reference |
| `hooks` | info | A hook configured for Claude Code |
| `methodology-tools` | info | A marker of Superpowers, GSD, Spec Kit, or OpenSpec |
| `unreadable` | info | A file the script could not parse |

User-level locations print as `user-level:<source>:<item>`; hooks show only the event and the program name. The script never prints a home path, hook arguments, or a secret value, and it runs Python in isolated mode so nothing in the target can execute.

## Check what the script cannot

Read the instruction files and skill descriptions the script listed, then look for:

- **Competing triggers:** skills with different names whose descriptions claim the same situation, especially against the playbook's `initialize-agent-workflow`, `execute-task-workflow`, and `review-task` (for example a plugin brainstorming skill that fires on "build a feature" while the playbook's task workflow should select the route).
- **Contradictory instructions:** rules in different files, or against the playbook, that cannot both be followed (for example "commit tests with the implementation" against tests-first).
- **Blocking hooks or permissions:** a hook or permission rule that blocks or bypasses a playbook step, such as running tests or writing task artifacts.
- **Stale instructions:** references to tools, paths, or commands that no longer exist.
- **Competing methodologies:** two methodology tools both active as workflow owner; confirm with the evidence rules in [`integrations.md`](integrations.md#detecting-existing-integrations) before calling it a conflict.

Record each as kind `judgment: <short slug>` with the locations involved.

## Report

Report the `Setup audit` findings first in onboarding, as described in [`onboarding.md`](onboarding.md#asking): number them `A1`, `A2`, … and ask each as its own question, with the evidence and one recommendation (keep, remove, rename, merge, or name a primary owner) offered first. List warnings and judgment findings; mention `info` lines only when they matter for a decision. When nothing needs a decision, say so in one line of the opening message, including whether user-level setup was included.

## Fix

- Nothing changes without an explicit yes for that finding.
- Repository findings the owner approves are fixed after initialization and its validation, as a separate step with its own diff. Rerun the script afterwards; approved repository findings must be gone. User-level findings stay until the owner makes the change.
- The agent never fixes user-level setup. It prints the exact change for the owner to make (which file, which entry, or which plugin to disable).

## Record

Record every decided finding in the `## AI setup audit` section of `docs/agent/integrations.md`, created from [`templates/integration-map.md`](templates/integration-map.md): Kind, Location (exactly as the script printed it), Decision, and Source `owner, <YYYY-MM-DD>`. Never record a home path or a skill body. A warning recorded with decision `keep` is reported by the script as `info (accepted)` and no longer fails the audit.

## Update mode

Rerun the audit with the recorded permission. Report only findings whose kind and location are not in the table, and judgment findings not already decided. The audit never re-asks a recorded decision.

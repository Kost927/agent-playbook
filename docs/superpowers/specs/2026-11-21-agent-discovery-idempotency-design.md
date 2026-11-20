# Agent Discovery and Idempotency — Design

Date: 2026-11-21
Status: approved

## Intent

Initialized repositories must actually be discoverable by both Claude Code and Codex, and repeated initialization must produce no diff.

Verified facts (2026-11-21):

- Codex discovers repository skills at `.agents/skills/<name>/SKILL.md`, scanning from the working directory up to the repository root, and reads `AGENTS.md`. Source: https://developers.openai.com/codex/skills
- Claude Code discovers project skills only at `.claude/skills/<name>/SKILL.md` and reads `AGENTS.md` only when no `CLAUDE.md` exists; `CLAUDE.md` can import it with an `@AGENTS.md` line. Approval prompts apply only to imports outside the working directory, so an in-repo import needs no prompt (corrected after review). Source: https://code.claude.com/docs/en/skills

Today `bootstrap.md` installs skills only to `.agents/skills/` and treats the Claude path as an unspecified "documented adapter", and `AGENTS.md`/`CLAUDE.md` duplicate the same managed content. Map templates carry `Last verified`/`Verified on` dates and SHAs that change on every run, contradicting the "repeated run produces no diff" rule.

## Goals

- `AGENTS.md` holds the managed entry-point block; `CLAUDE.md` imports it with `@AGENTS.md` plus optional Claude-only lines.
- Skills: canonical copy in `.agents/skills/`; identical generated copy in `.claude/skills/` when Claude Code is a configured agent; validation confirms the copies match.
- Date/SHA fields change only when the file's facts change.

## Non-goals

- User-global skill locations, plugins, or marketplace packaging.
- Agents other than Claude Code and Codex.

## Anti-goals

- Symlinks (Windows needs admin/Developer Mode; git may check them out as text files).
- Two divergent skill copies.
- Silent first-run surprise: the `@AGENTS.md` approval prompt must be mentioned in the final report.

## Approaches considered

| Option | Trade-off | Decision |
| --- | --- | --- |
| Generated identical copy in `.claude/skills/` | Works on all platforms; needs a match check | **Chosen** |
| Symlink `.claude/skills` → `.agents/skills` | Single source; breaks on Windows and some git setups | Rejected |
| Only `.agents/skills/` | No duplication; Claude Code never sees the skills | Rejected |

## Design

### Entry points (`bootstrap.md` steps 4, 5, 6, 7)

- `AGENTS.md`: the managed block between `agent-playbook` markers (read the local workflow and project map, route selection, questions and checkpoints, verified commands, preserve tests, report checks, independent review).
- `CLAUDE.md`: an `@AGENTS.md` line inside its own managed markers; Claude-specific content outside the markers is preserved. If `CLAUDE.md` already has substantial content, add the import without moving that content.
- Validation step "point to the same canonical workflow" becomes: `CLAUDE.md` imports `AGENTS.md`.

### Skills (`bootstrap.md` step 4.1, `skills/initialize-agent-workflow/SKILL.md`)

- Canonical: `.agents/skills/<name>/SKILL.md` (Codex path).
- When Claude Code is configured (repository evidence or the user's request): generated identical copy at `.claude/skills/<name>/SKILL.md`.
- Both copies carry the same generated header with source URL and revision.
- Validation: the two copies are byte-identical; update mode refreshes both.

### Idempotency (`bootstrap.md` operating contract and step 7; map and local-workflow templates)

- `Last verified against commit`, `Verified on`, and `Last reconciled` change only when other content of the same file changes in that run.
- The no-write second pass therefore proposes no changes.

### Other updates

- `README.md` "What initialization creates": show `.agents/skills/` and `.claude/skills/`, and describe `CLAUDE.md` as importing `AGENTS.md`.
- `scripts/validate.sh`: phrase checks for the new rules.

## Left to the builder

- Exact managed-block wording in `AGENTS.md`.
- Whether to add an entry-point template file or describe it inline in `bootstrap.md`.

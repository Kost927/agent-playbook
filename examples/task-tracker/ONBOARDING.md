# Onboarding

> **Synthetic example.** Both sides of this exchange were written by the playbook authors to show the onboarding described in [`onboarding.md`](../../onboarding.md). It is not a transcript of a real session.

Starting state: the request did not include permission to read user-level AI setup.

---

**Agent:** May I read the names and descriptions of your user-level skills, plugins, and MCP servers (`~/.claude`, `~/.codex`, `~/.cursor`, `~/.agents`) to find conflicts? Nothing is copied into the repository except the names of items you make decisions about.

**Human:** No.

*Why: `audit.md` asks this once, at the very start, when the request does not grant it; without a yes the audit stays repository-only.*

---

Discovery and the repository audit are done (commands, units, and workstreams are in the project and capability maps; `scripts/audit-ai-setup.sh` reported only two `instruction-sources` lines), and no agent files are written yet.

**Agent:** Discovery and the audit are done. Setup audit (repository only, as you asked): nothing conflicting; `AGENTS.md` and `CLAUDE.md` are the only instruction files, and `CLAUDE.md` imports `AGENTS.md`. Four short questions follow, one at a time.

*Why: `onboarding.md` opens with one short message, and the audit needs no decision here, so it stays one line.*

---

Each question below is shown as a structured question tool shows it (in Claude Code, `AskUserQuestion`): context, options with the recommendation first, and free text for the owner's own answer.

```text
Risk zones (1 of 4): migrations/ changes durable data and existing migrations
are never edited; src/tracker/db.py owns the connection and the migration
runner. Which paths need a minimum route?

1. migrations/ → Standard, db.py → Standard (Recommended)
2. migrations/ → Standard only
3. None
4. Other: write your own answer
```

**Human:** Other: migrations/ → Standard; db.py is not a risk zone, ordinary changes there are covered by `tests/test_db.py`.

```text
Staging (2 of 4): I found only CI, no deploy configuration. Is there a staging
or preview environment?

1. None (Recommended)
2. Yes: write how to reach it
```

**Human:** 1.

*Why: with no staging, the follow-up about using it for acceptance checks is moot and is skipped.*

```text
Independent review (3 of 4): what should review Standard and Full changes?

1. A different vendor's agent in a fresh session (Recommended)
2. Another model in a fresh session
3. The same model in a fresh session
4. Other
```

**Human:** Other: Codex in a fresh session.

```text
Models (4 of 4): which models serve deep, standard, and fast work?

1. session default for all three (Recommended)
2. Other: name them
```

**Human:** 1.

```text
Tools (nothing is installed without your yes). CI runs on GitHub Actions
(.github/workflows/ci.yml). Pick any you want; none selected means none.

[ ] GitHub MCP: lets an agent read CI results and pull requests
```

**Human:** None; I use `gh`.

*Why: browser automation is not offered because the only human-facing surface is the CLI; every tool is tied to something found in the repository.*

---

**Agent (recorded):**

- Capability map, `## Risk zones`: `migrations/`, minimum route Standard, source `owner, 2026-11-21`. `src/tracker/db.py` under `Considered, not risk zones`, so it is not suggested again.
- Project map: staging `none (owner, 2026-11-21)`.
- Model roster: all tiers `session default`; Independent review `Codex, fresh session (owner, 2026-11-21)`.
- GitHub MCP declined: recorded as `declined` in the tools table of `docs/agent/integrations.md`, so it is not offered again. No methodology integration is active.

*Why: `onboarding.md` records owner answers with their source, keeps declined suggestions, and never presents owner statements as verified facts.*

---

## What the agent deliberately did not ask

- Commands, units, and contracts: discovery found them in `pyproject.toml`, CI, and the code.
- Whether the API needs authentication: the capability map already records that it binds to `127.0.0.1`, and any wider exposure triggers the Full route.
- Whether the owner works alone or in a team: no rule changes with the answer.

# Onboarding

> **Synthetic example.** Both sides of this exchange were written by the playbook authors to show the onboarding described in [`onboarding.md`](../../onboarding.md). It is not a transcript of a real session.

Starting state: the request did not include permission to read user-level AI setup.

---

**Agent:** May I read the names and descriptions of your user-level skills, plugins, and MCP servers (`~/.claude`, `~/.codex`, `~/.cursor`, `~/.agents`) to find conflicts? Nothing is copied into the repository except the names of items you make decisions about.

**Human:** No.

*Why: `audit.md` asks this once, at the very start, when the request does not grant it; without a yes the audit stays repository-only.*

---

Discovery and the repository audit are done (commands, units, and workstreams are in the project and capability maps; `scripts/audit-ai-setup.sh` reported only two `instruction-sources` lines), and no agent files are written yet.

**Agent:** **Setup audit** (repository only, as you asked): nothing conflicting. `AGENTS.md` and `CLAUDE.md` are the only instruction files, and `CLAUDE.md` imports `AGENTS.md`.

Before I write the agent files, four questions the code cannot answer. Answer briefly, for example "1a ok, 2 none".

**1. Risk zones.** I recommend:

- a) `migrations/` — changes durable data, and existing migrations are never edited → minimum route Standard.
- b) `src/tracker/db.py` — owns the connection and migration runner → minimum route Standard.

Is either wrong, and is anything missing?

**2. Staging.** I found no deploy configuration, only CI. Is there a staging or preview environment? My recommendation: "none".

**3. Independent review.** What should review Standard and Full changes? My recommendation: a different vendor's agent in a fresh session.

**4. Models.** Which models serve deep, standard, and fast work, or `session default` for all?

**Tools** (nothing is installed without your yes):

- GitHub MCP: CI runs on GitHub Actions (`.github/workflows/ci.yml`); it lets an agent read CI results and pull requests.

I am not recommending browser automation: the only human-facing surface is the CLI.

*Why: `audit.md` puts the audit at the top of the onboarding message and keeps it to one line when nothing needs a decision; `onboarding.md` asks only what discovery could not settle, leads each question with a recommendation and its evidence, and ties every tool to something found in the repository.*

---

**Human:** 1a ok. 1b no, ordinary changes there are covered by `tests/test_db.py`. 2 none. 3 Codex in a fresh session. 4 session default. GitHub MCP no, I use `gh`.

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

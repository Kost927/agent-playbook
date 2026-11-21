# Onboarding

Use this procedure from [`bootstrap.md`](bootstrap.md) after discovering repository facts and deriving workstreams, and before planning files. Some facts that decide the route of later tasks are not in the code: where a change can lose money or data, whether there is a staging environment, what performs independent review, and which models serve each tier. The agent asks the owner for these one question at a time, with options to choose from, records the answers, and recommends tools that fit what it found.

## When to run

- First initialization of an existing repository.
- Greenfield initialization, after the interview in [`greenfield.md`](greenfield.md). Skip everything the request, `README`, interview, or product brief already settles. Risk zones name planned areas from the brief or stack ADR instead of paths.
- Update mode, once, when `docs/agent/capability-map.md` has no `## Risk zones` section: the repository was initialized before onboarding existed.

## What to ask

Ask only what discovery could not settle. Never ask what the code, documentation, request, or interview answers. For each question, lead with your recommendation and the evidence behind it.

1. **Risk zones.** Paths where a change involves payments, authorization, sensitive data, or difficult rollback, with the minimum route for each (usually Full; Standard for migrations that never touch existing production data). Propose candidates from evidence: module names, schemas, migrations, auth middleware, payment SDKs, encryption, deletion jobs.
2. **Staging or preview.** Whether one exists and how it is reached, when discovery found none or could not tell. Whenever a staging or preview environment exists, discovered or stated, also ask whether agents may use it for acceptance checks and with which test account or test mode: record the account name only, never a password; credentials come from environment variables or a secret store.
3. **Independent review.** What reviews Standard and Full changes: another vendor's coding agent, another model, or a fresh session.
4. **Model roster.** Concrete models for the deep, standard, and fast tiers, or `session default`.

Drop a question whose answer is already recorded or discovered. If nothing is left to ask and no tool fits, say so in the final report instead of sending an empty message.

## Asking

Ask as described in *How to ask* in the playbook's `workflow.md`: one decision at a time, with options and the recommendation first. With a structured question tool (for example `AskUserQuestion` in Claude Code), each question has a one-line context, 2–4 options with the recommended one first and marked `(Recommended)`, and free text for the owner's own answer; up to four independent questions may share one call, and a question that depends on another's answer goes in a later call. Without one, ask one question per message with options `a)`, `b)`, `c)` and "or write your own answer". Ask in the language the owner uses; record answers in English.

Order:

1. One short message saying what discovery and the audit found and how many decisions follow.
2. Each `Setup audit` finding from [`audit.md`](audit.md) (`A1`, `A2`, …) as its own question: the evidence in the context line, and keep, remove, rename, merge, or a primary owner as options.
3. The questions above that are still open, in order; skip any that an earlier answer made moot (no staging means no question about using it).
4. Tool recommendations: one multiple-choice question with one option per tool and its reason (nothing selected means none); with a single tool, a yes/no question; with more than four, one question per need.

Example question, as a structured tool would show it:

```text
Risk zones (1 of 4): src/billing/ calls the payment provider SDK, and
migrations/ changes durable data. Which paths need a minimum route?

a) billing → Full, migrations → Standard (Recommended)
b) billing → Full only
c) None of these
(the tool adds a free-text choice for your own answer)
```

## Waiting and unanswered questions

- Wait for the owner's reply before writing files.
- If the run is non-interactive (including a structured question tool that is unavailable or fails without a human) or the owner defers, write `unknown — asked, not answered (<YYYY-MM-DD>)` in each affected place and repeat the questions in the final report. A follow-up that depends on an unanswered question is recorded as `not asked`. That state is stable: a repeated run with no new answers changes nothing.
- "ok" on a recommendation is the owner's answer. Silence is never acceptance.

## Recording answers

- **Risk zones** go to the `## Risk zones` section of `docs/agent/capability-map.md`: one row per zone with Zone, Paths, Why, Minimum route, and Source `owner, <YYYY-MM-DD>`. When the owner names none, write a single `none stated` row; when the question went unanswered, write a single `unknown — asked, not answered (<YYYY-MM-DD>)` row. Paths the agent suggested and the owner declined go to the `Considered, not risk zones` line with `(owner, <YYYY-MM-DD>)`, so they are not suggested again.
- **Staging** goes to the project map's `Staging or preview environment` line, and the acceptance-check permission with the test account name or mode to its `Agents may use it for acceptance checks` line, each with a `(owner, <YYYY-MM-DD>)` suffix.
- **Review and models** go to the model roster in `docs/agent/workflow.md`, including the `Independent review` row, each owner answer with a `(owner, <YYYY-MM-DD>)` suffix.
- Owner statements are never presented as verified facts. Where discovery later confirms one (for example a staging deploy job appears), record the evidence next to it.

## Recommending tools

Follow [`integrations.md`](integrations.md#recommending-mcp-servers-and-plugins). Recommend only for a need found in the repository, give the reason in one line, and recommend nothing when nothing fits. Do not offer a tool already recorded as `declined` in the tools table of `docs/agent/integrations.md`.

## After an explicit yes

Approval is an explicit yes for a named item; approving one tool approves only that tool.

1. Finish initialization and its validation first.
2. Then, as a separate step with its own diff, add each approved MCP server to the project-scope configuration of the configured agents (for example `.mcp.json` for Claude Code, `.codex/config.toml` for Codex, `.cursor/mcp.json` for Cursor), with a pinned version and environment-variable references instead of secrets.
3. Plugins and skill packs install at user scope: print the exact install command for the owner to run, and record the tool as `approved, owner installs`.
4. Record every recommendation the owner answered in the `## Tools (MCP servers and plugins)` table of `docs/agent/integrations.md`, created from [`templates/integration-map.md`](templates/integration-map.md): `configured`, `approved, owner installs`, or `declined`.

## Update mode

Onboarding never re-asks recorded answers. In update mode, ask only about:

- candidate risk-zone paths that appear neither in the risk-zones table nor in `Considered, not risk zones`;
- entries still `unknown — asked, not answered`;
- roster rows that are missing, or `session default` when the owner asks to fill them.

Asking again about an `asked, not answered` entry does not change the file until an answer arrives.

Onboarding may add the `Independent review` row and fill roster rows that are missing, `unknown — asked, not answered`, or `session default` when the owner asks, only from the owner's answers; it never changes another recorded model.

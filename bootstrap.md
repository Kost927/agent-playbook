# Bootstrap and Update Procedure

This document tells an agent how to initialize or update the workflow in a target repository. The target repository's existing instructions always take precedence over this playbook.

## Operating contract

- Work in the target repository, not in this playbook repository.
- Inspect before editing. Never guess commands, paths, frameworks, or conventions.
- Preserve existing work, local instructions, and unrelated changes.
- Write generated documentation in English unless the target repository explicitly requires another language.
- Do not install dependencies, change production code, or run destructive commands merely to initialize documentation.
- Do not install, initialize, update, or remove an external agent plugin, skill pack, CLI, MCP server, or workflow framework without explicit human approval.
- Treat the playbook as a process source and the target repository as the factual source.
- Record the playbook source (URL or local path) and the exact commit SHA or tag used.
- A repeated run against the same playbook revision and repository state must produce no diff.
- Date and commit fields (`Last verified against commit`, `Verified on`, `Last reconciled`) change only when other content of the same file changes in that run. `Playbook revision` always records the pinned playbook revision. `Last verified against commit` is the target repository `HEAD` at verification time; if the worktree has uncommitted changes, note that under unknowns.

## Initialization algorithm

### 1. Establish scope and constraints

Before step 1.1, settle permission for the user-level part of the AI setup audit: use the request's permission line or the decision recorded in `docs/agent/integrations.md`; otherwise ask the one yes/no question from [`audit.md`](audit.md#permission-for-user-level-setup) and wait. In a non-interactive run, audit the repository only.

1. Use the directory the user names as the target root. Only when none is named, use `git rev-parse --show-toplevel`. If the target is nested inside another repository, record that in the final report.
2. Read instruction files from the repository root down to relevant subdirectories, including `AGENTS.md`, `CLAUDE.md`, Cursor rules (`.cursor/rules/*.mdc`, and `.cursorrules` if present), `README`, contribution guides, and tool-specific rule files.
3. Inspect `git status` and preserve all existing changes.
4. Map repository boundaries: independently built, tested, deployed, published, or owned units and their relationships. Do not force them into a frontend/backend taxonomy.
5. Identify security, generated-file, and validation constraints before editing.
6. Inventory existing agent tooling and durable workflow artifacts using [`integrations.md`](integrations.md). Detect configuration and generated files, but do not execute or modify third-party tooling during discovery.
   Then run the AI setup audit from [`audit.md`](audit.md): the read-only `scripts/audit-ai-setup.sh` plus judgment checks for competing skills, contradictory instructions, and blocking hooks. Use `--global` only with the permission settled before step 1.1. Do not fix anything yet.
7. Determine whether the repository is greenfield as defined in [`greenfield.md`](greenfield.md). Files created by this playbook do not count against greenfield, and an existing `docs/agent/product-brief.md` means a greenfield initialization is resuming. If greenfield, follow that procedure instead of step 2, then continue from step 3, deriving `planned` workstreams from the product brief and stack ADR.

If instructions conflict, follow the more specific target-repository instruction and document the conflict in the final report.

### 2. Discover verified project facts

Inspect manifests, lockfiles, CI configuration, build configuration, test configuration, deployment definitions, schemas, and representative modules. Record evidence for:

- package manager and runtime versions;
- entry points, modules, ownership boundaries, and dependency direction;
- build, static analysis, formatting, test, packaging, generation, migration, and validation commands;
- inbound and outbound contracts, persistence, state, messaging, jobs, error handling, caching, and generated artifacts;
- user or machine interfaces, accessibility or protocol constraints, compatibility guarantees, and good examples;
- an existing design system for human-facing interfaces (component library, design tokens), recorded in the capability map, and `none found` when absent;
- a mutation-testing tool already configured (for example mutmut, Stryker, PIT, or cargo-mutants), recorded in the project map, and `none found` when absent;
- release, deployment, rollback, and observability mechanisms when present;
- security scanning already configured in CI or tooling: static analysis (SAST), dependency audit, and dynamic scans (DAST), recorded as `none found` when absent.

Prefer a real file path and a short explanation over generic advice. When documentation disagrees with CI or configuration, record the discrepancy rather than silently choosing one.

### 3. Derive capability workstreams

Read [`profiles/capability-workstreams.md`](profiles/capability-workstreams.md). Build a capability map from repository evidence rather than choosing a language or framework profile. A repository may activate any combination of interaction surfaces, service/contract boundaries, persistence, asynchronous processing, libraries, infrastructure, security, or delivery workstreams.

For each detected capability record its scope, owning paths, inputs/outputs, compatibility constraints, commands, examples, and validation evidence. Omit unsupported workstreams. Mark incomplete evidence as unknown instead of guessing.

For a monorepo, first map shared root policy and the dependency graph, then repeat discovery at each boundary with distinct commands or constraints. Create nested instructions only where specificity is useful; more specific instructions inherit rather than duplicate root policy.

### 3.1 Onboard the owner

Follow [`onboarding.md`](onboarding.md): send one message, starting with the `Setup audit` findings from step 1.6, with the questions discovery could not settle (risk zones, staging, independent review, models) and evidence-tied tool recommendations, then wait for answers before step 4. Unanswered questions are recorded as `unknown — asked, not answered (<YYYY-MM-DD>)`. In greenfield, onboarding follows the interview and skips what the product brief settles.

### 4. Plan files before writing

At minimum, initialize:

- `AGENTS.md` — entry point read by Codex and Cursor (Cursor reads it in the root and in subdirectories, so it needs no separate entry point or `.cursor/rules` file); holds the managed entry-point block from [`templates/agents-entry.md`](templates/agents-entry.md), with only the test command filled in;
- `CLAUDE.md` — entry point read by Claude Code, which reads `AGENTS.md` only when no `CLAUDE.md` exists; contains the `@AGENTS.md` import inside managed markers from [`templates/claude-entry.md`](templates/claude-entry.md), plus optional Claude-only content outside them. When Claude Code is configured, every managed `AGENTS.md`, including nested ones, gets a sibling `CLAUDE.md` that imports it. If `CLAUDE.md` is a symlink to `AGENTS.md`, leave it unchanged; if it already imports `AGENTS.md` outside the markers, do not add a second import;
- `docs/agent/workflow.md` — local workflow based on [`templates/local-workflow.md`](templates/local-workflow.md);
- `docs/agent/project-map.md` — verified structure and commands based on [`templates/project-map.md`](templates/project-map.md);
- `docs/agent/capability-map.md` — applicable workstreams based on [`templates/capability-map.md`](templates/capability-map.md).
- `docs/agent/product-brief.md` and the stack ADR — greenfield only, as described in [`greenfield.md`](greenfield.md). The ADR goes to `docs/adr/0001-stack.md` unless the repository already has an ADR location and numbering, which then win;
- `docs/agent/integrations.md` — only when an external workflow tool is already present or explicitly approved, or onboarding recorded a tool recommendation answer, based on [`templates/integration-map.md`](templates/integration-map.md).
- project-local workflow skills for configured coding agents, sourced from [`skills/`](skills/).

Add subsystem-specific documents only when the capability map shows that a distinct boundary needs more detail. Their names and contents should follow the repository's terminology, not predefined frontend/backend labels.

Do not create empty task artifacts during initialization. Specifications, task cards, handoffs, ADRs, and review reports belong to concrete tasks. The one exception is greenfield initialization, which records the stack ADR and a scaffolding task card because they are the concrete next step.

If multiple methodology tools are present, do not merge their generated directories or run competing lifecycle commands. Establish one primary workflow owner and map secondary tools to non-overlapping roles using [`integrations.md`](integrations.md). Ask for a decision when ownership is ambiguous.

### 4.1 Install project-local workflow skills

Treat a direct request to “initialize agents” or “initialize the agent workflow” as authorization to create project-local workflow files and skill copies inside the target repository. It does not authorize writing to user-global configuration or installing third-party software.

1. Determine which coding agents are configured. An agent is configured when its files are already present (`.claude/` or `CLAUDE.md` for Claude Code; `.codex/` or `AGENTS.md` for Codex; `.cursor/` or `.cursorrules` for Cursor) or when the user's request names it.
2. Use [`skills/initialize-agent-workflow/SKILL.md`](skills/initialize-agent-workflow/SKILL.md), [`skills/execute-task-workflow/SKILL.md`](skills/execute-task-workflow/SKILL.md), and [`skills/review-task/SKILL.md`](skills/review-task/SKILL.md) as source templates.
3. Write the canonical copy to `.agents/skills/<skill-name>/SKILL.md`, the repository skill path Codex discovers. Cursor reads skills from `.agents/skills/` too, so Cursor needs no copy of its own; never create `.cursor/skills/` copies.
4. When Claude Code is configured, write a byte-identical generated copy to `.claude/skills/<skill-name>/SKILL.md`, the only project path Claude Code discovers. Do not use a symlink: Windows and some git setups break them. Create no other copies.
5. Add a generated header directly after the YAML frontmatter, as one HTML comment in this form: `<!-- Generated by the Agent Playbook. Source: <playbook URL or path>. Revision: <tag or SHA>. -->`. The fixed opening lets the AI setup audit recognize playbook copies wherever the playbook came from; the frontmatter must stay the first thing in the file. Do not edit the semantic frontmatter fields in a way that changes skill routing.
6. Keep the skills thin: they load `docs/agent/*`; they must not embed a second copy of the shared workflow.
7. On update, refresh both generated copies from the pinned playbook revision, keep them byte-identical, and preserve documented manual extension points.

If agent configuration is ambiguous, create the canonical `.agents/skills/` copy and ask in the final report whether to add the `.claude/skills/` copy, rather than guessing a global or vendor-specific location.

### 5. Merge safely

When an output file already exists:

1. Read it in full.
2. Preserve its instructions and prose.
3. Add only missing links or sections necessary to connect the shared workflow.
4. Prefer referencing `docs/agent/workflow.md` over duplicating the full process in `AGENTS.md`. `CLAUDE.md` imports `AGENTS.md` with `@AGENTS.md` instead of repeating it; if `CLAUDE.md` already has content, add the import without moving or deleting that content.
5. Never replace a manually maintained file wholesale.

Use these stable HTML markers only when the target repository has no conflicting convention:

```markdown
<!-- agent-playbook:start -->
Managed entry-point content.
<!-- agent-playbook:end -->
```

Only content inside the markers may be refreshed automatically. Content outside them is owned by the target repository. If legacy generated content has no markers, make a conservative manual merge and add markers only around newly managed content.

### 6. Populate local instructions

The `AGENTS.md` managed block (imported by `CLAUDE.md`) comes verbatim from [`templates/agents-entry.md`](templates/agents-entry.md); only the test command is repository-specific. Read the template for its exact rules: it points agents to the local workflow and project map, route selection, questions and checkpoints, acceptance criteria, verified commands, preserved tests, honest reporting, and independent review.

In `docs/agent/workflow.md`, fill the repository-owned model roster below the managed block from the user's request, or write `session default`; never guess model names.

The project and capability maps must distinguish verified facts from unknowns. Do not state that a command works unless it was found in repository configuration or successfully executed. Never present a `planned` entry as verified.

### 7. Validate

Before reporting completion:

1. Confirm every documented local path exists; for `planned` entries, confirm they match the stack ADR instead.
2. Confirm commands match manifests, scripts, CI, or tool configuration; `planned` commands must match the stack ADR.
3. Check that each managed `AGENTS.md` points to `docs/agent/workflow.md`, and that each `CLAUDE.md` imports its sibling `AGENTS.md` exactly once (or is a symlink to it).
4. Confirm the capability map has a `## Risk zones` section, and that risk zones, staging, and roster entries from onboarding carry their source or `asked, not answered`.
5. Check that every activated workstream contains repository-specific evidence, or is `planned` and traced to the product brief or stack ADR, and that unsupported workstreams were not added.
6. If integrations are active, confirm their versions, artifact ownership, command boundaries, and conflict policy are recorded.
7. Validate every generated skill with the available skill validator or, when unavailable, verify YAML frontmatter, folder/name consistency, local references, and absence of scaffold placeholders. Confirm every `.claude/skills/` copy is byte-identical to its `.agents/skills/` source.
8. Review the diff for duplicated or overwritten manual content.
9. Run `scripts/check-target.sh --agents <configured agents> <target-dir>` from the playbook checkout (for example `--agents claude,codex` or `--agents codex,cursor`) and include its output in the report. Also run the safest relevant documentation or repository checks available.
10. If the owner approved audit fixes, apply them after this validation as a separate step and rerun `scripts/audit-ai-setup.sh`; approved repository findings must be gone (user-level findings disappear only after the owner makes the change).
11. Run a no-write second pass: re-derive the facts from the repository, compare them with the maps, and run the checker again. It must propose no further changes.

Report the playbook source and revision, files created or changed, evidence inspected, validations run, unresolved facts, and final diff summary.

## Update mode

Use update mode when agent files already record a playbook revision.

1. Read the currently recorded source and revision.
2. Read the requested new playbook revision and identify process/template differences.
3. Re-scan target-repository facts that may have changed since initialization, and rerun the audit from [`audit.md`](audit.md) with the recorded user-level permission; report only findings not already decided.
4. Re-check every `planned` entry; mark it `verified` with evidence, or keep or correct it and report it as a discrepancy. Do not silently delete it. Re-check `proposed` ADRs and report any still awaiting human confirmation.
5. Update only marked managed sections and factual sections whose evidence changed.
6. Preserve local decisions, manual additions, and stricter repository rules; keep the repository's model roster as it is, with one exception: Onboarding may add the `Independent review` row and fill roster rows that are missing, `unknown — asked, not answered`, or `session default` when the owner asks, only from the owner's answers; it never changes another recorded model. If the capability map has no `## Risk zones` section, run [`onboarding.md`](onboarding.md) once; otherwise it asks only about new gaps.
7. If a new shared rule conflicts with a local rule, keep the local rule and report the conflict.
8. Validate as described above and run a no-write second pass for idempotency.

An update report must separate:

- changes inherited from the playbook;
- changes caused by new facts in the target repository;
- local content deliberately preserved;
- conflicts or follow-up decisions.

## Stop conditions

Stop and ask for direction when:

- the target repository cannot be identified safely;
- existing instructions are materially contradictory;
- completing setup would require overwriting substantial manual content;
- required access, credentials, or external repositories are unavailable;
- a product, security, or operational decision cannot be inferred from repository evidence (in a new repository this is handled by the greenfield interview).

Unknown facts are not an invitation to guess. Record them explicitly and leave the smallest safe setup.

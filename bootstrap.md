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
- Record the exact playbook URL and revision used.
- A repeated run against the same playbook revision and repository state must produce no diff.
- Date and commit fields (`Last verified against commit`, `Verified on`, `Last reconciled`) change only when other content of the same file changes in that run.

## Initialization algorithm

### 1. Establish scope and constraints

1. Confirm the target repository root with `git rev-parse --show-toplevel` when Git is available.
2. Read instruction files from the repository root down to relevant subdirectories, including `AGENTS.md`, `CLAUDE.md`, `README`, contribution guides, and tool-specific rule files.
3. Inspect `git status` and preserve all existing changes.
4. Map repository boundaries: independently built, tested, deployed, published, or owned units and their relationships. Do not force them into a frontend/backend taxonomy.
5. Identify security, generated-file, and validation constraints before editing.
6. Inventory existing agent tooling and durable workflow artifacts using [`integrations.md`](integrations.md). Detect configuration and generated files, but do not execute or modify third-party tooling during discovery.
7. Determine whether the repository is greenfield as defined in [`greenfield.md`](greenfield.md). Files created by this playbook do not count against greenfield, and an existing `docs/agent/product-brief.md` means a greenfield initialization is resuming. If greenfield, follow that procedure instead of step 2, then continue from step 3, deriving `planned` workstreams from the product brief and stack ADR.

If instructions conflict, follow the more specific target-repository instruction and document the conflict in the final report.

### 2. Discover verified project facts

Inspect manifests, lockfiles, CI configuration, build configuration, test configuration, deployment definitions, schemas, and representative modules. Record evidence for:

- package manager and runtime versions;
- entry points, modules, ownership boundaries, and dependency direction;
- build, static analysis, formatting, test, packaging, generation, migration, and validation commands;
- inbound and outbound contracts, persistence, state, messaging, jobs, error handling, caching, and generated artifacts;
- user or machine interfaces, accessibility or protocol constraints, compatibility guarantees, and good examples;
- release, deployment, rollback, and observability mechanisms when present.

Prefer a real file path and a short explanation over generic advice. When documentation disagrees with CI or configuration, record the discrepancy rather than silently choosing one.

### 3. Derive capability workstreams

Read [`profiles/capability-workstreams.md`](profiles/capability-workstreams.md). Build a capability map from repository evidence rather than choosing a language or framework profile. A repository may activate any combination of interaction surfaces, service/contract boundaries, persistence, asynchronous processing, libraries, infrastructure, security, or delivery workstreams.

For each detected capability record its scope, owning paths, inputs/outputs, compatibility constraints, commands, examples, and validation evidence. Omit unsupported workstreams. Mark incomplete evidence as unknown instead of guessing.

For a monorepo, first map shared root policy and the dependency graph, then repeat discovery at each boundary with distinct commands or constraints. Create nested instructions only where specificity is useful; more specific instructions inherit rather than duplicate root policy.

### 4. Plan files before writing

At minimum, initialize:

- `AGENTS.md` — entry point read by Codex; holds the managed entry-point block;
- `CLAUDE.md` — entry point read by Claude Code, which does not read `AGENTS.md` itself; contains an `@AGENTS.md` import inside managed markers, plus optional Claude-only content outside them. Where nested instruction files exist, a nested `CLAUDE.md` imports its sibling `AGENTS.md`;
- `docs/agent/workflow.md` — local workflow based on [`templates/local-workflow.md`](templates/local-workflow.md);
- `docs/agent/project-map.md` — verified structure and commands based on [`templates/project-map.md`](templates/project-map.md);
- `docs/agent/capability-map.md` — applicable workstreams based on [`templates/capability-map.md`](templates/capability-map.md).
- `docs/agent/product-brief.md` and `docs/adr/0001-stack.md` — greenfield only, as described in [`greenfield.md`](greenfield.md);
- `docs/agent/integrations.md` — only when an external workflow tool is already present or explicitly approved, based on [`templates/integration-map.md`](templates/integration-map.md).
- project-local workflow skills for configured coding agents, sourced from [`skills/`](skills/).

Add subsystem-specific documents only when the capability map shows that a distinct boundary needs more detail. Their names and contents should follow the repository's terminology, not predefined frontend/backend labels.

Do not create empty task artifacts during initialization. Specifications, task cards, handoffs, ADRs, and review reports belong to concrete tasks. The one exception is greenfield initialization, which records the stack ADR and a scaffolding task card because they are the concrete next step.

If multiple methodology tools are present, do not merge their generated directories or run competing lifecycle commands. Establish one primary workflow owner and map secondary tools to non-overlapping roles using [`integrations.md`](integrations.md). Ask for a decision when ownership is ambiguous.

### 4.1 Install project-local workflow skills

Treat a direct request to “initialize agents” or “initialize the agent workflow” as authorization to create project-local workflow files and adapters inside the target repository. It does not authorize writing to user-global configuration or installing third-party software.

1. Determine which coding agents are configured from repository evidence and the user's request.
2. Use [`skills/initialize-agent-workflow/SKILL.md`](skills/initialize-agent-workflow/SKILL.md), [`skills/execute-task-workflow/SKILL.md`](skills/execute-task-workflow/SKILL.md), and [`skills/review-task/SKILL.md`](skills/review-task/SKILL.md) as source templates.
3. Prefer `.agents/skills/<skill-name>/SKILL.md` as the canonical project-local source when supported by the configured agents.
4. When a configured agent requires a different project-local discovery path, create its documented adapter or generated copy. Record the mapping and do not create duplicate discoverable skills for one agent.
5. Add a generated header or managed metadata that records the source playbook URL and revision. Do not edit the semantic frontmatter fields in a way that changes skill routing.
6. Keep the skills thin: they load `docs/agent/*`; they must not embed a second copy of the shared workflow.
7. On update, refresh generated skill content from the pinned playbook revision and preserve documented manual extension points.

If agent configuration is ambiguous, initialize the canonical `.agents/skills/` copy and report which tool-specific adapter remains unresolved rather than guessing a global or vendor-specific location.

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

The `AGENTS.md` managed block (imported by `CLAUDE.md`) should be short and refer to one canonical local workflow. It must tell agents to:

- read `docs/agent/workflow.md` and `docs/agent/project-map.md`;
- inspect the task and select a route before coding;
- ask questions and run checkpoints as described in *Questions and checkpoints* in `docs/agent/workflow.md`;
- write acceptance criteria for standard and full routes;
- use verified repository commands;
- preserve agreed tests;
- report checks actually run and remaining risk;
- use an independent, fresh-context review for meaningful changes.

The project and capability maps must distinguish verified facts from unknowns. Do not state that a command works unless it was found in repository configuration or successfully executed. Never present a `planned` entry as verified.

### 7. Validate

Before reporting completion:

1. Confirm every documented local path exists; for `planned` entries, confirm they match the stack ADR instead.
2. Confirm commands match manifests, scripts, CI, or tool configuration; `planned` commands must match the stack ADR.
3. Check that each `CLAUDE.md` imports its sibling `AGENTS.md` with `@AGENTS.md`.
4. Check that every activated workstream contains repository-specific evidence, or is `planned` and traced to the product brief or stack ADR, and that unsupported workstreams were not added.
5. If integrations are active, confirm their versions, artifact ownership, command boundaries, and conflict policy are recorded.
6. Validate every generated skill with the available skill validator or, when unavailable, verify YAML frontmatter, folder/name consistency, local references, and absence of scaffold placeholders.
7. Review the diff for duplicated or overwritten manual content.
8. Run the safest relevant documentation or repository checks available.
9. Repeat the initialization logic without writing; it must propose no further changes.

Report the playbook source and revision, files created or changed, evidence inspected, validations run, unresolved facts, and final diff summary. When `CLAUDE.md` was created or changed, note that Claude Code shows a one-time approval prompt for the `@AGENTS.md` import.

## Update mode

Use update mode when agent files already record a playbook revision.

1. Read the currently recorded source and revision.
2. Read the requested new playbook revision and identify process/template differences.
3. Re-scan target-repository facts that may have changed since initialization.
4. Re-check every `planned` entry; mark it `verified` with evidence, or keep or correct it and report it as a discrepancy. Do not silently delete it. Re-check `proposed` ADRs and report any still awaiting human confirmation.
5. Update only marked managed sections and factual sections whose evidence changed.
6. Preserve local decisions, manual additions, and stricter repository rules.
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

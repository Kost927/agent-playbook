# Optional Workflow Integrations

The core playbook is complete without external plugins. Integrations are optional adapters that may automate discovery, specification, planning, testing, execution, or review. They must not create a second source of truth or silently replace the repository's accepted workflow.

Tool behavior and installation instructions change. Before adopting or updating an integration, read its current official documentation, pin an appropriate version or revision, inspect the files and permissions it introduces, and obtain explicit human approval before installation or initialization.

## Selection principles

1. Start from a concrete workflow problem, not tool popularity.
2. Prefer an already adopted repository tool when it adequately covers the need.
3. Choose one **primary workflow owner** for specifications, task state, and lifecycle transitions.
4. Use secondary tools only for explicitly non-overlapping capabilities.
5. Keep original requirements, accepted criteria, and review evidence durable and accessible to every agent involved.
6. Do not let generated prompts override repository instructions, security policy, or human decisions.
7. Trial a tool on one representative task and evaluate intervention rate, artifact quality, review findings, runtime/cost, and rollback before broad adoption.
8. Record the tool, version, configuration, generated paths, owners, commands, and removal procedure in the target repository.

## Integration catalog

This catalog is a starting point, not an endorsement ranking.

### Superpowers

Official source: [obra/superpowers](https://github.com/obra/superpowers)

Superpowers presents a composable agent-skills framework and software-development methodology. Consider it when the desired gap is disciplined brainstorming, planning, test-driven implementation, debugging, or review skills across supported coding agents.

Potential mapping:

| Playbook stage | Adapter role |
| --- | --- |
| Discover/specify | Brainstorming and plan-writing skills may produce a draft for human acceptance |
| Test/implement | Test-driven and execution skills may implement accepted task cards |
| Review | Review-request and review-response skills may support—but not replace—independent acceptance-criteria review |

Conflict rule: if Superpowers owns planning or task execution, do not also let another full methodology independently create a competing plan. Store or link the accepted output from the repository's canonical task artifacts.

### Get Shit Done (GSD)

Official sources: [gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done) and its [documentation](https://github.com/gsd-build/get-shit-done/blob/main/docs/README.md)

GSD describes itself as a context-engineering and spec-driven development system for coding agents. Consider it when a project needs a more opinionated project/phase/task lifecycle, context management, and execution orchestration.

Potential mapping:

| Playbook concept | GSD adapter responsibility |
| --- | --- |
| Specification and roadmap | GSD planning artifacts may become the canonical artifacts if explicitly selected |
| Task cards and handoffs | GSD phase/plan state may replace equivalent playbook templates, with links recorded in the integration map |
| Implementation | GSD execution may implement accepted tasks using repository commands and capability workstreams |
| Independent review | Keep a fresh reviewer outside the implementation context and provide original requirements plus canonical GSD artifacts |

Conflict rule: do not maintain parallel playbook task cards and GSD task state. Select one canonical lifecycle and map the other to it.

### GitHub Spec Kit

Official sources: [github/spec-kit](https://github.com/github/spec-kit) and [Spec Kit documentation](https://github.github.com/spec-kit/)

Spec Kit is a toolkit for spec-driven development with coordinated prompts, templates, scripts, and agent integrations. Consider it when the main need is a structured specification-to-plan-to-task workflow and the team wants its generated artifacts to be the canonical specification set.

Potential mapping:

| Playbook concept | Spec Kit adapter responsibility |
| --- | --- |
| Specification | Spec Kit feature specification becomes the canonical requirement artifact |
| Design/plan | Spec Kit planning output records architecture and capability-workstream implications |
| Tasks | Generated tasks carry acceptance-criterion IDs and verification methods |
| Review | Reviewer reads the original request, canonical spec/plan/tasks, and diff independently |

Conflict rule: do not generate a second playbook specification for the same change. Add missing acceptance, risk, or capability information to the selected canonical artifacts or a clearly linked supplement.

### OpenSpec

Official sources: [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec) and its [current documentation](https://openspec.dev/docs)

OpenSpec uses repository-resident specifications and change artifacts, including proposal, spec deltas, design, tasks, and archival into the current system specification. Consider it for brownfield repositories that want durable behavioral specifications and explicit change deltas shared across coding agents.

Potential mapping:

| Playbook concept | OpenSpec adapter responsibility |
| --- | --- |
| Original and current behavior | Main specs and change deltas become canonical behavioral requirements |
| Specification/design/tasks | OpenSpec change artifacts replace equivalent playbook templates |
| Implementation | Apply only an accepted change and preserve requirement/scenario intent |
| Completion | Review acceptance evidence before archive; archive only after the repository's completion policy is met |

Conflict rule: OpenSpec's specs and changes should be the single source of truth when selected. Do not duplicate them under another SDD tool or `docs/agent` task templates.

## Detecting existing integrations

Use read-only inspection. Look for documented configuration, generated directories, skill/command files, dependencies, lockfile entries, CI jobs, and references in repository instructions. Do not identify a tool from one coincidental filename; corroborate it with documentation, metadata, or generated markers.

For every detected tool, determine:

- whether it is active, legacy, partially removed, or merely mentioned;
- installed/pinned version or revision, if verifiable;
- repository-local versus user-global scope;
- files it owns or generates;
- lifecycle commands the team actually uses;
- whether those commands modify or delete files;
- overlap with other tools and the core playbook;
- current owner and safe removal/update path.

Never run an installer, initializer, migration, update, or cleanup command as part of detection.

## Adoption decision

Recommend **no integration** when the core playbook is sufficient. Otherwise return a short decision record:

| Field | Required content |
| --- | --- |
| Problem | The repeated failure or cost the integration should reduce |
| Candidate | Tool and pinned version/revision considered |
| Fit | Playbook stages it improves |
| Ownership | Canonical artifacts and lifecycle it will own |
| Boundaries | What remains owned by the playbook or another tool |
| Costs/risks | Setup, permissions, generated files, conflicts, runtime/cost, lock-in |
| Trial | One representative task and measurable success signals |
| Rollback | How to disable/remove it without losing accepted requirements or history |

Installation or initialization is a separate, explicitly approved action after this decision.

## Artifact precedence

When an integration is active, precedence is:

1. Human decisions and target-repository instructions.
2. Original request and explicitly accepted product/security/operational decisions.
3. The recorded canonical specification and task artifacts owned by the selected primary tool.
4. The local project and capability maps.
5. Generated prompts, skills, plugin defaults, and implementer summaries.

If two sources at the same level conflict, stop and resolve the conflict explicitly. Never choose whichever instruction is more convenient for implementation.

## Independent review boundary

Regardless of the primary tool, meaningful changes retain an independent review path. The reviewer receives original requirements, canonical artifacts, contracts, affected capability workstreams, the diff, and repository access. A plugin's “completed” state is evidence of workflow progress, not proof that acceptance criteria are met.

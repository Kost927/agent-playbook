# Task: `001 — Scaffold the Team Notes service`

Route: `Standard`  
Status: `blocked`  
Tests commit: `not yet created (written by the test author before implementation)`

Blocked until ADR-0001 (`docs/adr/0001-stack.md`) is accepted.

## Outcome

`A minimal runnable project matching ADR-0001, with working build, test, and lint commands`

## Acceptance criteria

- `AC-1` — `npm ci` and `npm run build` succeed from a clean checkout.
- `AC-2` — `npm test` runs at least one trivial test and passes.
- `AC-3` — lint, format, and type checks run (`npm run lint`, `npm run typecheck`; format command chosen during scaffolding).
- `AC-4` — The commands match ADR-0001 and are recorded in the project map.
- `AC-5` — Bootstrap update mode has been run and every `planned` entry is `verified` or listed as a discrepancy.

## Affected scope

- Units/boundaries: the planned Team Notes web service.
- Active capability workstreams: infrastructure and delivery; interaction surface and data and state only as empty skeletons.
- Downstream consumers: none yet.

## Dependencies and relevant files

- Depends on: ADR-0001 accepted.
- Read first: `docs/agent/product-brief.md`, `docs/adr/0001-stack.md`, `docs/agent/project-map.md`.
- Preferred examples: none found (no code yet).

## Constraints

- No product features (agent proposal: at most a health page); notes, search, and sign-in are later tasks.
- No paid services (product brief).

## Test plan

| Criterion | Test level and scenario | Expected pre-fix result |
| --- | --- | --- |
| `AC-1` | Command: clean checkout, `npm ci && npm run build` | Fails: no project yet |
| `AC-2` | Unit: a trivial test (agent proposal: health handler) | Fails: no project yet |
| `AC-3` | Command: lint, format, and type-check scripts | Fail: no project yet |
| `AC-4` | Review: commands in the project map match ADR-0001 | Not applicable before scaffolding |
| `AC-5` | Bootstrap update mode report | Not applicable before scaffolding |

## Definition of done

- Acceptance criteria have implementation and verification evidence.
- Relevant verified commands pass, or failures are documented.
- The diff contains no unrelated changes.
- Remaining risk and unrun checks are recorded.

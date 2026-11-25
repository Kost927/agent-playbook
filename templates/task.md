# Task: `<TASK_ID> — <TITLE>`

Route: `<Direct | Fast | Standard | Full>`  
Status: `<ready | in progress | review | done | blocked>`  
Tests commit: `<sha of each tests-only commit in order, n/a for Direct/Fast, or n/a — no test runner>`  
Acceptance plan commit: `<sha of each plan-only commit in order when the acceptance tester will run, or n/a>`  
Acceptance plan hash: `<hash carried by the latest acceptance plan commit message, only when task artifacts are not committed; otherwise n/a>`

## Outcome

`<One independently acceptable behavior>`

## Acceptance criteria

- `<AC-ID>` — `<criterion summary>`

## Affected scope

- Units/boundaries: `<repository terms and paths>`
- Active capability workstreams: `<detected concerns>`
- Downstream consumers: `<verified consumers or unknown>`

## Dependencies and relevant files

- Depends on: `<task/decision/contract or none>`
- Read first: `<paths>`
- Preferred examples: `<paths and why>`

## Size check

- Expected diff: `<about N changed lines, excluding generated files and lockfiles>`
- Implementation sessions: `<1, or why more>`
- Split decision: `<not needed, split into task IDs, or reason it cannot be split>`

## Constraints

- `<compatibility, security, architecture, or scope constraint>`

## Test plan

| Criterion | Test level and scenario | Expected pre-fix result |
| --- | --- | --- |
| `<AC-ID>` | `<unit/integration/E2E/manual>` | `<meaningful failure>` |

## Definition of done

- Acceptance criteria have implementation and verification evidence.
- Relevant verified commands pass, or failures are documented.
- The diff contains no unrelated changes.
- Remaining risk and unrun checks are recorded.

# Acceptance: `<TASK_ID> — <TITLE>`

Specification: `<path to the canonical specification>`  
UX flow: `<path, or n/a>`  
Where it runs: `<local command, preview URL, or staging URL the project map allows agents to use>`  
Test account or mode: `<account name or test mode; never a real customer account or real payment>`

## Plan

Written by the test author from the acceptance criteria before implementation and committed before the implementation commit (with the tests, or alone when there is no test runner). Neither the implementer nor the tester edits this section; a wrong step is escalated and fixed in a new plan-only commit.

| AC | Steps | Expected observable result |
| --- | --- | --- |
| `<AC-ID>` | `<numbered steps a person or browser tool can follow>` | `<what is seen, in the user's terms>` |

## Results

Filled by the acceptance tester (the playbook's `roles/acceptance-tester.md`) after implementation.

Tester: `<tool and model>` · Tool used: `<Playwright MCP, Playwright CLI, CLI, or none>` · Run on: `<YYYY-MM-DD, environment>`

| AC | Observed | Evidence | Result |
| --- | --- | --- | --- |
| `<AC-ID>` | `<what actually happened>` | `<path under the task folder's evidence/>` | `<pass, fail, or not run — reason>` |

## Findings

- `<failed or blocked criterion, with steps to reproduce; or none>`

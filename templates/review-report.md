# Review Report: `<TASK_ID>`

Implementer: `<tool and model>`  
Reviewer: `<tool and model; a different model family when available>`

## Findings

List findings in severity order. For each finding include severity, file/location, related acceptance criterion or invariant, triggering scenario, expected versus actual behavior, and user/operational impact.

If there are no material findings, state that explicitly and continue with coverage and residual risk.

## Acceptance-criteria coverage

| Criterion | Implementation evidence | Test/verification evidence | Status |
| --- | --- | --- | --- |
| `<AC-ID>` | `<path and behavior>` | `<test/command/result>` | `<met/partial/not met/unverified>` |

## Test integrity

Output of `scripts/check-tests-diff.sh --repo <target> --tests-commit <latest sha> <base>`, a note that the test diff from the tests commit was read, and an explanation for every reported item. An unexplained item is a blocking finding.

| Reported item | Explanation | Blocking? |
| --- | --- | --- |
| `<kind: path>` | `<why the change is legitimate, or the finding>` | `<yes/no>` |

## Checks performed

| Check | Result | Notes |
| --- | --- | --- |
| `<command or scenario>` | `<pass/fail>` | `<relevant output>` |

## Checks not performed

- `<check>` — `<reason and resulting uncertainty>`

## Residual risks and non-blocking improvements

- `<risk not disproven by this review>`

# `<TASK_ID> — <TITLE>`

## Summary

`<one or two sentences on the observable change>`

- Original request: `<link or quote>`
- Specification: `<path>`
- Route: `<Direct | Fast | Standard | Full>`

## Acceptance criteria evidence

| Criterion | Implementation | Verification |
| --- | --- | --- |
| `<AC-ID>` | `<path and behavior>` | `<test name, command result, or observed behavior>` |

## Commits

- Tests commit: `<sha, or n/a for Direct/Fast>`
- Acceptance plan commit: `<sha of each plan commit in order, or n/a>`; acceptance plan results: `<path to acceptance.md, or n/a>`; owner accepted `not run`: `<AC-IDs and date, or none>`
- `<sha>` — `<subject>` (Task: `<id>`, AC: `<ids>`)

## Checks run

| Check | Command | Result |
| --- | --- | --- |
| `<tests, lint, build, ...>` | `<command from the project map>` | `<pass/fail>` |

Mutation testing (Full, critical domain logic): `<command and score, or not run — reason>`

Not run: `<check — reason>`

## Test integrity

Output of `scripts/check-tests-diff.sh --repo <target> --tests-commit <sha> <base>` and how each reported item was explained in review, or `n/a — Direct/Fast`, or `n/a — no test runner`.

## Security checks

On Direct/Fast routes this section may be `n/a — Direct/Fast`.

| Check | Command | Result |
| --- | --- | --- |
| Static analysis (SAST) | `<command, or none found>` | `<result or not run — reason>` |
| Dependency audit | `<command, or none found>` | `<result or not run — reason>` |
| Dynamic scan (DAST, Full with a web surface only) | `<command, or not applicable>` | `<result or not run — reason>` |

## Migration and rollback

- Migration: `<none, or what changes and how it was tested>`
- Rollback: `<mechanism and whether it was tried>`

## Monitoring after release

`<signals to watch, thresholds, and for how long, taken from the service's operational context>`

## Review

- Implementer: `<tool and model>`
- Reviewer: `<tool and model>`
- Review report: `<path>`

## Release note

`<user-facing summary; copy into the changelog only if the repository keeps one>`

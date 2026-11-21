# Test Integrity — Design

Date: 2026-11-21
Status: approved

## Intent

The source video (19:49–20:17) describes the oracle problem: an agent deletes or weakens a test and reports "all green". The playbook forbids this and asks the reviewer to check, but nothing detects it mechanically.

## Goals

- Standard/Full: the test author commits tests alone before implementation; the task card records `Tests commit: <sha>`; the implementer does not modify those test files afterwards (a wrong test is escalated, not edited).
- `scripts/check-tests-diff.sh <base> [<head>] [--tests-commit <sha>]`: a language-neutral report of suspicious test changes in a target repository:
  - deleted test files;
  - removed test definitions;
  - added skip/focus markers;
  - fewer assertions in test files than before;
  - test files changed after the tests commit.
- The script reports, it does not decide: the reviewer must explain every reported item in the review report's new "Test integrity" section; an unexplained item is a blocking finding.
- Fixture tests for the script.

## Non-goals

- Language-specific parsers or coverage tools.
- Blocking commits or CI in target repositories.

## Anti-goals

- Presenting a clean script result as proof that tests were not weakened.

## Approaches considered

| Option | Trade-off | Decision |
| --- | --- | --- |
| Heuristic diff report + tests-first commit | Language-neutral, cheap; can miss subtle weakening or flag honest refactors | **Chosen** |
| Process rules only | No tooling; relies on agent honesty, which is the failure mode | Rejected |
| Mutation testing as the integrity check | Strong signal; language-specific and slow | Deferred to a later item |

## Design

Patterns (case-sensitive where noted in the script):

- Test files: path segment `test`/`tests`/`__tests__`/`spec`, or names `test_*`, `*_test.*`, `*.test.*`, `*.spec.*`, `*Test.*`, `*Tests.*`.
- Test definitions: `def test`, `func Test`, `it(`, `test(`, `describe(`, `@Test`, `#[test]`, `[Fact]`, `[Test]`.
- Skip/focus markers: `skip`, `xfail`, `.only(`, `xit(`, `xdescribe(`, `@Disabled`, `@Ignore`, `t.Skip`, `#[ignore]`, `pending(`.
- Assertions: `assert`, `expect(`, `should`, `require.`, `Assert.`, `t.Error`, `t.Fatal`.

Output: one line per finding, `<kind>: <path>[:<detail>]`, exit 0 with "No suspicious test changes" when clean, exit 1 when findings exist, exit 2 on usage errors.

References: `workflow.md` step 6 and 9, `roles/implementer.md`, `roles/reviewer.md`, `skills/review-task`, `templates/task.md` (`Tests commit:`), `templates/review-report.md` (`## Test integrity`), condensed rule in `templates/local-workflow.md`.

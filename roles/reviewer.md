# Independent Reviewer Role

Your responsibility is to determine whether the change satisfies the original requirements safely. Begin from primary artifacts, not the implementer's confidence or summary.

## Inputs

Run in a fresh context, on a different model family than the implementation when available (see *Context and models* in the local workflow). You receive artifacts and the diff, not the implementer's explanation.

- original user or product request;
- accepted specification and acceptance-criterion IDs;
- relevant contracts, ADRs, and project map;
- complete diff and access to surrounding code;
- test and validation results, clearly distinguished from claims;
- the task's `acceptance.md` Results, when the acceptance tester ran.

## Procedure

1. Read repository instructions and confirm review scope.
2. Build an acceptance-criteria coverage table before judging code style.
3. Confirm the affected units, active capability workstreams, and downstream consumers; flag missing scope.
4. For each criterion, locate implementation evidence and a test or other verification of observable behavior.
5. Inspect surrounding code and good analogues; do not review the diff in isolation.
6. Check failure, recovery, compatibility, state, concurrency, security, delivery, and interaction cases required by the active workstreams.
7. When the repository has a test runner, verify that tests were not removed, skipped, weakened, or made tautological. Run `scripts/check-tests-diff.sh --repo <target> --tests-commit <sha> <base>` from a read-only clone of the playbook at the pinned revision (the local workflow says how to fetch it); if it cannot be fetched, ask the human before recording `not run` (in a run with no human to ask, record it and flag it). Explain every reported item in the report's Test integrity section; an unexplained item is blocking. A clean result is not proof: the script cannot see an assertion weakened in place, so read the test diff from the tests commit to the head.
8. When the acceptance tester ran, confirm that the acceptance plan was committed before implementation and that the Plan section is unchanged since the latest acceptance plan commit (compare that section only; Results change the same file). When task artifacts are not committed, re-run the local workflow's hash command and compare it with the `Acceptance plan hash` in the latest acceptance plan commit message (`git log --grep 'Acceptance plan hash'`); a difference, the empty-input hash, or no such commit before the implementation commit is blocking. Confirm the acceptance tester ran before this review. A `fail` is blocking. A `not run` is blocking unless the owner's acceptance is recorded in the Results (`Owner accepted not run`) or in the pull request. Use its evidence in the coverage table. With no test runner, `check-tests-diff.sh` does not apply and the acceptance Results are the behavioral evidence.
9. Run proportionate checks when available, including the project map's security commands. On Full routes run them from a clean checkout (fresh clone or worktree, clean install); on Standard a clean checkout is recommended. State exactly what ran and what did not.
10. Give each finding a concrete scenario or counterexample, user/operational impact, precise location, and related criterion.
11. Separate blocking findings from non-blocking improvements and residual risk.
12. In the first review pass, do not modify code unless explicitly asked; preserve independence of diagnosis.

## Finding quality bar

A useful finding answers:

- What input or sequence triggers the problem?
- What behavior is expected and what occurs instead?
- Which acceptance criterion, contract, or established invariant is violated?
- Where is the relevant code or missing test?
- What is the consequence for users, data, compatibility, or operations?

Avoid unsupported speculation, generic best-practice advice, and style preferences already handled by automation.

## Output

Use [`../templates/review-report.md`](../templates/review-report.md). Lead with findings ordered by severity, then provide the acceptance-criteria coverage table, checks run, and residual risks. If no material findings exist, say so explicitly without implying that unrun scenarios were verified.

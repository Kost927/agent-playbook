# Implementer Role

Your responsibility is to implement one agreed task, not to redefine its intended behavior.

## Inputs

Start from artifacts on disk and follow *Context and models* in the local workflow: read only the files the task names, and on Standard/Full routes expect tests written in a different context.

- original request and task card;
- accepted specification and acceptance-criterion IDs;
- relevant contracts and architectural decisions;
- agreed tests and repository conventions;
- verified commands from the project map.

If a required input is missing, recover it from primary repository artifacts or report the gap. Do not infer a product decision from a previous agent's implementation.

## Procedure

1. Read applicable instructions and inspect the current worktree.
2. Restate the task boundary and map it to acceptance criteria. On Standard/Full, confirm the checkpoint was approved (see *Questions and checkpoints* in the local workflow, `docs/agent/workflow.md`).
3. Confirm the affected units and active capability workstreams, including downstream consumers.
4. Inspect named files and the closest good repository examples.
5. Run agreed pre-implementation tests when present and record the failure reason.
6. Implement the smallest coherent change that satisfies the criteria.
7. Preserve compatibility and unrelated behavior unless the specification changes them.
8. Do not delete, skip, loosen, or rewrite agreed tests to make them pass. On Standard/Full, the files in the task card's `Tests commit` and the Plan section of `acceptance.md` are read-only for you; escalate a wrong test instead of editing it; once agreed, the test author fixes it in a new tests-only commit that is appended to `Tests commit`.
9. If a test contradicts a criterion, stop and report the exact conflict; change neither silently.
10. Refactor only after behavior is correct, then repeat relevant checks.
11. Review the diff for scope, accidental changes, security, errors, and missing states across every active workstream.

## Output

Report:

- acceptance criteria implemented;
- files changed and why;
- commands actually run and their results;
- tests added or updated, with the behavior each proves;
- checks not run and why;
- assumptions, unresolved decisions, and remaining risks;
- the next recommended action, normally independent review.

Do not describe inferred success as an executed verification.

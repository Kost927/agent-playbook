#!/usr/bin/env bash
# Report suspicious test changes between two commits of a target repository. Never writes.
#
# Usage: scripts/check-tests-diff.sh [--repo <dir>] [--tests-commit <sha>] <base> [<head>]
#   --repo          repository to inspect (default: current directory)
#   --tests-commit  commit holding the agreed tests; test files changed after it are reported
# Exit codes: 0 no findings, 1 findings, 2 usage error.
#
# This is a heuristic for reviewers: a clean result does not prove tests were not weakened,
# and a finding may be an honest refactor. The reviewer explains every finding.
set -euo pipefail

repo="."
tests_commit=""
positional=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) repo="${2:?}"; shift 2 ;;
    --tests-commit) tests_commit="${2:?}"; shift 2 ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) positional+=("$1"); shift ;;
  esac
done
if [[ ${#positional[@]} -lt 1 || ${#positional[@]} -gt 2 ]]; then
  echo "usage: $0 [--repo <dir>] [--tests-commit <sha>] <base> [<head>]" >&2
  exit 2
fi

python3 - "$repo" "$tests_commit" "${positional[0]}" "${positional[1]:-HEAD}" <<'PY'
import re
import subprocess
import sys

repo, tests_commit, base, head = sys.argv[1:5]


def git(*args):
    result = subprocess.run(["git", "-C", repo, *args], capture_output=True, text=True, errors="replace")
    if result.returncode != 0:
        usage(f"git {' '.join(args)} failed: {result.stderr.strip()}")
    return result.stdout


def usage(message):
    print(f"usage error: {message}", file=sys.stderr)
    sys.exit(2)


for ref in (base, head, *( [tests_commit] if tests_commit else [] )):
    if subprocess.run(["git", "-C", repo, "rev-parse", "--verify", "--quiet", ref + "^{commit}"], capture_output=True).returncode != 0:
        usage(f"unknown commit {ref!r}")
if tests_commit and subprocess.run(["git", "-C", repo, "merge-base", "--is-ancestor", tests_commit, head]).returncode != 0:
    usage(f"--tests-commit {tests_commit} is not an ancestor of {head}")

TEST_PATH = re.compile(
    r"(^|/)(tests?|__tests__|spec|specs)/"
    r"|(^|/)test_[^/]+$|_test\.[^/]+$|\.(test|spec)\.[^/]+$|(^|/)[^/]*Tests?\.[^/]+$"
)
TEST_DEF = re.compile(r"\bdef test|\bfunc Test|\b(it|test|describe)\s*\(|@Test\b|#\[test\]|\[Fact\]|\[Test\]")
SKIP = re.compile(r"\bskip|\bxfail\b|\.only\s*\(|\bx(it|describe)\s*\(|@Disabled\b|@Ignore\b|\bt\.Skip|#\[ignore\]|\bpending\s*\(", re.IGNORECASE)
ASSERTION = re.compile(r"\bassert|\bexpect\s*\(|\.should\b|\brequire\.|\bAssert\.|\bt\.(Error|Fatal)")


def is_test(path):
    return bool(TEST_PATH.search(path))


findings = []
status = git("diff", "--find-renames", "--name-status", base, head)
for line in status.splitlines():
    parts = line.split("\t")
    kind, paths = parts[0], parts[1:]
    if kind.startswith("D") and is_test(paths[0]):
        findings.append(f"deleted-test-file: {paths[0]}")

changed = [p for p in git("diff", "--find-renames", "--name-only", base, head).splitlines() if is_test(p)]
for path in changed:
    diff = git("diff", "--find-renames", "-U0", base, head, "--", path)
    removed = [l[1:] for l in diff.splitlines() if l.startswith("-") and not l.startswith("---")]
    added = [l[1:] for l in diff.splitlines() if l.startswith("+") and not l.startswith("+++")]
    removed_defs = sum(bool(TEST_DEF.search(l)) for l in removed)
    added_defs = sum(bool(TEST_DEF.search(l)) for l in added)
    if removed_defs > added_defs:
        findings.append(f"removed-test: {path}: {removed_defs - added_defs} test definition(s) removed")
    new_skips = sum(bool(SKIP.search(l)) for l in added) - sum(bool(SKIP.search(l)) for l in removed)
    if new_skips > 0:
        findings.append(f"skip-marker: {path}: {new_skips} skip or focus marker(s) added")
    lost = sum(bool(ASSERTION.search(l)) for l in removed) - sum(bool(ASSERTION.search(l)) for l in added)
    if lost > 0:
        findings.append(f"fewer-assertions: {path}: {lost} assertion(s) fewer")

if tests_commit:
    agreed = [p for p in git("ls-tree", "-r", "--name-only", tests_commit).splitlines() if is_test(p)]
    after = set(git("diff", "--name-only", tests_commit, head).splitlines())
    for path in agreed:
        if path in after:
            findings.append(f"changed-after-tests-commit: {path}")

if findings:
    print("\n".join(findings))
    print(f"{len(findings)} suspicious test change(s). The reviewer must explain each one.", file=sys.stderr)
    sys.exit(1)
print("No suspicious test changes found (heuristic; not proof).")
PY

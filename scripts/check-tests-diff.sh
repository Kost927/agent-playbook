#!/usr/bin/env bash
# Report suspicious test changes in a target repository. Never writes.
#
# Usage: scripts/check-tests-diff.sh [--repo <dir>] [--tests-commit <sha>] <base> [<head>]
#   --repo          repository to inspect (default: current directory)
#   --tests-commit  the tests-only commit recorded in the task card; agreed tests are compared from it to <head>
#   <base>          branch or commit the change started from; the script diffs from merge-base(<base>, <head>)
# Exit codes: 0 no findings, 1 findings, 2 usage or internal error.
#
# Heuristic for reviewers. It cannot see an assertion weakened in place (for example `== 3` changed to
# `is not None`), so a clean result is not proof: read the test diff. A finding may be an honest refactor;
# the reviewer explains every one.
set -uo pipefail

usage() { echo "usage: $0 [--repo <dir>] [--tests-commit <sha>] <base> [<head>]" >&2; exit 2; }

repo="."
tests_commit=""
positional=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) [[ $# -ge 2 && -n "$2" ]] || usage; repo="$2"; shift 2 ;;
    --tests-commit) [[ $# -ge 2 && -n "$2" && "$2" != -* ]] || usage; tests_commit="$2"; shift 2 ;;
    -h|--help) sed -n '2,13p' "$0"; exit 0 ;;
    -*) usage ;;
    *) positional+=("$1"); shift ;;
  esac
done
[[ ${#positional[@]} -ge 1 && ${#positional[@]} -le 2 ]] || usage

python3 - "$repo" "$tests_commit" "${positional[0]}" "${positional[1]:-HEAD}" <<'PY'
import re
import subprocess
import sys

repo, tests_commit, base_ref, head = sys.argv[1:5]


def fail(message):
    print(f"usage error: {message}", file=sys.stderr)
    sys.exit(2)


def git(*args, check=True):
    result = subprocess.run(["git", "-c", "core.quotePath=false", "-C", repo, *args],
                            capture_output=True, text=True, encoding="utf-8", errors="replace")
    if check and result.returncode != 0:
        fail(f"git {' '.join(args)} failed: {result.stderr.strip()}")
    return result


TEST_PATH = re.compile(
    r"(^|/)(tests?|__tests__|spec|specs)/"
    r"|(^|/)test_[^/]+$|_(test|spec)\.[^/]+$|\.(test|spec)\.[^/]+$|(^|/)[^/]*Tests?\.[^/]+$|(^|/)tests\.py$"
)
TEST_CONFIG = re.compile(
    r"(^|/)(conftest\.py|pytest\.ini|tox\.ini|phpunit\.xml(\.dist)?|\.mocharc\.[^/]+|karma\.conf\.[^/]+"
    r"|(jest|vitest|playwright|cypress)\.config\.[^/]+)$"
)
TEST_DEF = re.compile(r"\bdef test|\bfunc Test|(?<![.\w])(it|test|describe)\s*\(|@Test\b|#\[test\]|\[Fact\]|\[Test\]")
SKIP = re.compile(
    r"(?<![\w])skip\s*\(|\.skip\b|mark\.skip|@skip|unittest\.skip|\bxfail\b|\.only\s*\(|(?<![.\w])x(it|describe)\s*\("
    r"|@Disabled\b|@Ignore\b|\bt\.Skip|#\[ignore\]|(?<![.\w])pending\s*\("
)
ASSERTION = re.compile(r"\bassert|\bexpect\s*\(|\.should\b|\brequire\.|\bAssert\.|\bXCTAssert|\bt\.(Error|Fatal)")


def is_test(path):
    return bool(TEST_PATH.search(path)) or bool(TEST_CONFIG.search(path))


def changed_lines(diff_text):
    removed, added, in_hunk = [], [], False
    for line in diff_text.splitlines():
        if line.startswith("@@"):
            in_hunk = True
        elif line.startswith("diff --git"):
            in_hunk = False
        elif in_hunk and line.startswith("-"):
            removed.append(line[1:])
        elif in_hunk and line.startswith("+"):
            added.append(line[1:])
    return removed, added


def count(pattern, lines):
    return sum(len(pattern.findall(line)) for line in lines)


def line_findings(old, new, path, old_path=None):
    diff = git("diff", "-U0", "--no-renames", old, new, "--", *( [old_path] if old_path and old_path != path else [] ), path).stdout
    removed, added = changed_lines(diff)
    found = []
    if TEST_CONFIG.search(path) and (removed or added):
        found.append(f"test-config-changed: {path}")
    if count(TEST_DEF, removed) > count(TEST_DEF, added):
        found.append(f"removed-test: {path}: {count(TEST_DEF, removed) - count(TEST_DEF, added)} test definition(s) removed")
    if count(SKIP, added) > count(SKIP, removed):
        found.append(f"skip-marker: {path}: {count(SKIP, added) - count(SKIP, removed)} skip or focus marker(s) added")
    if count(ASSERTION, removed) > count(ASSERTION, added):
        found.append(f"fewer-assertions: {path}: {count(ASSERTION, removed) - count(ASSERTION, added)} assertion(s) fewer")
    return found


try:
    for ref in [base_ref, head] + ([tests_commit] if tests_commit else []):
        if git("rev-parse", "--verify", "--quiet", ref + "^{commit}", check=False).returncode != 0:
            fail(f"unknown commit {ref!r}")
    if tests_commit and git("merge-base", "--is-ancestor", tests_commit, head, check=False).returncode != 0:
        fail(f"--tests-commit {tests_commit} is not an ancestor of {head}")
    base = git("merge-base", base_ref, head).stdout.strip()

    findings = []
    for line in git("diff", "--find-renames", "--name-status", base, head).stdout.splitlines():
        parts = line.split("\t")
        kind = parts[0]
        if kind.startswith("D") and is_test(parts[1]):
            findings.append(f"deleted-test-file: {parts[1]}")
        elif kind.startswith("R") and is_test(parts[1]):
            if not is_test(parts[2]):
                findings.append(f"moved-out-of-tests: {parts[1]} -> {parts[2]}")
            else:
                findings.extend(line_findings(base, head, parts[2], parts[1]))
        elif kind[0] in "AM" and is_test(parts[1]):
            findings.extend(line_findings(base, head, parts[1]))

    if tests_commit:
        agreed = [p for p in git("ls-tree", "-r", "--name-only", tests_commit).stdout.splitlines() if is_test(p)]
        status = {}
        for line in git("diff", "--no-renames", "--name-status", tests_commit, head).stdout.splitlines():
            kind, path = line.split("\t", 1)
            status[path] = kind
        for path in agreed:
            if status.get(path, "").startswith("D"):
                findings.append(f"agreed-test-removed-or-renamed: {path}")
            elif path in status:
                findings.append(f"changed-after-tests-commit: {path}")
                findings.extend(f"after tests commit, {item}" for item in line_findings(tests_commit, head, path))

    findings = list(dict.fromkeys(findings))
except SystemExit:
    raise
except Exception as error:  # report internal errors as exit 2, never as "findings"
    print(f"internal error: {error}", file=sys.stderr)
    sys.exit(2)

if findings:
    print("\n".join(findings))
    print(f"{len(findings)} suspicious test change(s). The reviewer must explain each one.", file=sys.stderr)
    sys.exit(1)
print("No suspicious test changes found (heuristic, not proof: still read the test diff).")
PY

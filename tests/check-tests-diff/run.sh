#!/usr/bin/env bash
# Fixture tests for scripts/check-tests-diff.sh: each case builds a small git history and checks the report.
set -uo pipefail

playbook_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
checker="$playbook_root/scripts/check-tests-diff.sh"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
failures=0

repo() {
  rm -rf "$work/r"
  mkdir -p "$work/r/src" "$work/r/tests"
  git -C "$work/r" init -q
  git -C "$work/r" config user.email fixture@example.invalid
  git -C "$work/r" config user.name fixture
  printf 'def add(a, b):\n    return a + b\n# skip nothing here\n' > "$work/r/src/calc.py"
  printf 'from calc import add\n\ndef test_add():\n    assert add(1, 2) == 3\n    assert add(0, 0) == 0\n\ndef test_add_negative():\n    assert add(-1, 1) == 0\n' > "$work/r/tests/test_calc.py"
  git -C "$work/r" add -A && git -C "$work/r" commit -q -m base
  base="$(git -C "$work/r" rev-parse HEAD)"
}

commit() { git -C "$work/r" add -A && git -C "$work/r" commit -q -m change; }

expect() {
  local code="$1" needle="$2" name="$3"
  shift 3
  local output actual
  output="$(cd / && "$checker" --repo "$work/r" "$@" 2>&1)"; actual=$?
  if [[ "$actual" != "$code" ]] || [[ -n "$needle" && "$output" != *"$needle"* ]]; then
    echo "check-tests-diff case '$name': expected exit $code with '$needle', got $actual:" >&2
    echo "$output" >&2
    failures=$((failures + 1))
  fi
}

repo; printf 'def sub(a, b):\n    return a - b\n' >> "$work/r/src/calc.py"; commit
expect 0 "No suspicious test changes" "clean production change" "$base"

repo; git -C "$work/r" rm -q tests/test_calc.py; commit
expect 1 "deleted-test-file: tests/test_calc.py" "deleted test file" "$base"

repo; git -C "$work/r" mv tests/test_calc.py tests/test_arith.py; commit
expect 0 "No suspicious test changes" "renamed test file" "$base"

repo; python3 - "$work/r/tests/test_calc.py" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read().replace("\ndef test_add_negative():\n    assert add(-1, 1) == 0\n", "\n")
s = s.replace("    assert add(0, 0) == 0\n", "    assert add(0, 0) == 0\n    assert add(2, 2) == 4\n    assert add(3, 3) == 6\n")
open(p, "w").write(s)
PY
commit
expect 1 "removed-test: tests/test_calc.py" "removed test definition despite more assertions" "$base"

repo; python3 - "$work/r/tests/test_calc.py" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read().replace("def test_add_negative():", "@pytest.mark.skip\ndef test_add_negative():")
open(p, "w").write(s)
PY
commit
expect 1 "skip-marker: tests/test_calc.py" "added skip marker" "$base"

repo; printf '# skip this optimisation for now\n' >> "$work/r/src/calc.py"; commit
expect 0 "No suspicious test changes" "skip word in production file" "$base"

repo; python3 - "$work/r/tests/test_calc.py" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read().replace("    assert add(0, 0) == 0\n", "")
open(p, "w").write(s)
PY
commit
expect 1 "fewer-assertions: tests/test_calc.py" "fewer assertions" "$base"

repo; printf '\ndef test_add_big():\n    assert add(10, 10) == 20\n' >> "$work/r/tests/test_calc.py"; commit
tests_commit="$(git -C "$work/r" rev-parse HEAD)"
sed -i.bak 's/== 20/== 21/' "$work/r/tests/test_calc.py"; rm "$work/r/tests/test_calc.py.bak"; printf 'x = 1\n' >> "$work/r/src/calc.py"; commit
expect 1 "changed-after-tests-commit: tests/test_calc.py" "test edited after tests commit" "$base" --tests-commit "$tests_commit"

repo; printf 'x = 1\n' >> "$work/r/src/calc.py"; commit
git -C "$work/r" checkout -q -b other "$base"; printf 'y = 2\n' >> "$work/r/src/calc.py"; commit
other="$(git -C "$work/r" rev-parse HEAD)"; git -C "$work/r" checkout -q -
expect 2 "not an ancestor" "non-ancestor tests commit" "$base" --tests-commit "$other"

if (( failures > 0 )); then
  exit 1
fi
echo "check-tests-diff fixture tests passed."

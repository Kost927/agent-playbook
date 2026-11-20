#!/usr/bin/env bash
# Fixture tests for scripts/check-target.sh. Each case copies the example, mutates it, and asserts pass/fail.
set -uo pipefail

playbook_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
checker="$playbook_root/scripts/check-target.sh"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
failures=0

fresh() {
  rm -rf "$work/t"
  cp -R "$playbook_root/examples/task-tracker" "$work/t"
}

expect() {
  local expected="$1" name="$2"
  local output
  if output="$(cd / && "$checker" "$work/t" 2>&1)"; then actual=pass; else actual=fail; fi
  if [[ "$actual" != "$expected" ]]; then
    echo "check-target case '$name': expected $expected, got $actual" >&2
    echo "$output" >&2
    failures=$((failures + 1))
  fi
}

fresh; expect pass "unchanged example"

fresh; rm "$work/t/CLAUDE.md"; ln -s AGENTS.md "$work/t/CLAUDE.md"; expect pass "CLAUDE.md symlink"

fresh; rm "$work/t/CLAUDE.md"; expect pass "Codex only, no CLAUDE.md"

fresh; python3 - "$work/t/AGENTS.md" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read().replace("<!-- agent-playbook:end -->", "- Hand edit inside markers\n<!-- agent-playbook:end -->")
open(p, "w").write(s)
PY
expect fail "hand edit inside AGENTS.md markers"

fresh; printf '@AGENTS.md\n' >> "$work/t/CLAUDE.md"; expect fail "duplicate import"

fresh; mkdir -p "$work/t/.agents/skills/x" "$work/t/.claude/skills/x"
printf -- '---\nname: x\n---\na\n' > "$work/t/.agents/skills/x/SKILL.md"
printf -- '---\nname: x\n---\nb\n' > "$work/t/.claude/skills/x/SKILL.md"
expect fail "skill copies differ"

fresh; mkdir -p "$work/t/.agents/skills/x" "$work/t/.claude/skills/x"
printf -- '---\nname: x\n---\na\n' > "$work/t/.agents/skills/x/SKILL.md"
cp "$work/t/.agents/skills/x/SKILL.md" "$work/t/.claude/skills/x/SKILL.md"
expect pass "skill copies identical"

fresh; printf '\n`<X>`\n' >> "$work/t/docs/agent/project-map.md"; expect fail "placeholder in project map"

fresh; printf '\n[broken](missing.md)\n' >> "$work/t/docs/agent/capability-map.md"; expect fail "broken link"

fresh; rm "$work/t/docs/agent/capability-map.md"; expect fail "missing capability map"

if (( failures > 0 )); then
  exit 1
fi
echo "check-target fixture tests passed."

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
  shift 2
  local output
  if output="$(cd / && "$checker" --no-skills "$@" "$work/t" 2>&1)"; then actual=pass; else actual=fail; fi
  if [[ "$actual" != "$expected" ]]; then
    echo "check-target case '$name': expected $expected, got $actual" >&2
    echo "$output" >&2
    failures=$((failures + 1))
  fi
}

fresh; expect pass "unchanged example"

fresh; rm "$work/t/CLAUDE.md"; ln -s AGENTS.md "$work/t/CLAUDE.md"; expect pass "CLAUDE.md symlink"

fresh; rm "$work/t/CLAUDE.md"; expect pass "Codex only, no CLAUDE.md" --agents codex

fresh; rm "$work/t/CLAUDE.md"; expect fail "Claude requested but CLAUDE.md missing" --agents claude,codex

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

fresh; python3 - "$work/t/AGENTS.md" <<'PY2'
import sys
p = sys.argv[1]
s = open(p).read().replace("<!-- agent-playbook:start -->\n", "").replace("<!-- agent-playbook:end -->\n", "")
open(p, "w").write(s)
PY2
expect fail "root AGENTS.md without markers"

fresh; printf '# Claude\n\n<!-- agent-playbook:start -->\nsomething else\n<!-- agent-playbook:end -->\n\n@AGENTS.md\n' > "$work/t/CLAUDE.md"; expect fail "CLAUDE.md managed block differs"

fresh; mkdir -p "$work/t/node_modules/foo" "$work/t/vendor"; printf 'x\n' > "$work/t/node_modules/foo/CLAUDE.md"
printf '\xff\xfe<!-- agent-playbook:start -->\n' > "$work/t/vendor/AGENTS.md"; rm "$work/t/CLAUDE.md"
expect pass "vendored files ignored, Codex only" --agents codex

fresh; mkdir -p "$work/t/pkg"; cp "$work/t/AGENTS.md" "$work/t/pkg/AGENTS.md"; cp "$work/t/CLAUDE.md" "$work/t/pkg/CLAUDE.md"
printf '\n`<TEST_COMMAND>`\n' >> "$work/t/pkg/AGENTS.md"; expect fail "placeholder in nested AGENTS.md"

skills_fixture() {
  for skill in initialize-agent-workflow execute-task-workflow review-task; do
    mkdir -p "$work/t/.agents/skills/$skill" "$work/t/.claude/skills/$skill"
    printf -- '---\nname: %s\n---\nbody\n' "$skill" > "$work/t/.agents/skills/$skill/SKILL.md"
    cp "$work/t/.agents/skills/$skill/SKILL.md" "$work/t/.claude/skills/$skill/SKILL.md"
  done
}
expect_skills() {
  local expected="$1" name="$2"
  if (cd / && "$checker" "$work/t" >/dev/null 2>&1); then actual=pass; else actual=fail; fi
  if [[ "$actual" != "$expected" ]]; then
    echo "check-target case '$name': expected $expected, got $actual" >&2
    failures=$((failures + 1))
  fi
}
fresh; skills_fixture; expect_skills pass "all skills present in both locations"
fresh; expect_skills fail "skills required unless --no-skills"
fresh; skills_fixture; rm -r "$work/t/.claude/skills/review-task"; expect_skills fail "Claude copy missing for a canonical skill"

if (( failures > 0 )); then
  exit 1
fi
echo "check-target fixture tests passed."

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

fresh; mkdir -p "$work/t/urllib"; printf 'open("%s/PWNED", "w").write("x")\n' "$work" > "$work/t/urllib/__init__.py"; rm -f "$work/PWNED"
(cd "$work/t" && "$checker" --no-skills . >/dev/null 2>&1)
if [[ -e "$work/PWNED" ]]; then echo "check-target case 'no code from the target runs': target module was executed" >&2; failures=$((failures + 1)); fi

fresh; rm "$work/t/CLAUDE.md"; ln -s AGENTS.md "$work/t/CLAUDE.md"; expect pass "CLAUDE.md symlink"

fresh; rm "$work/t/CLAUDE.md"; expect pass "Codex only, no CLAUDE.md" --agents codex

fresh; rm "$work/t/CLAUDE.md"; expect fail "Claude requested but CLAUDE.md missing" --agents claude,codex

fresh; rm "$work/t/CLAUDE.md"; expect pass "Cursor only, no CLAUDE.md" --agents cursor

fresh; if out="$(cd / && "$checker" --no-skills --agents cursor,bogus "$work/t" 2>&1)"; then code=0; else code=$?; fi
if [[ "$code" != 2 || "$out" != *"unknown agent(s): bogus"* ]]; then
  echo "check-target case 'unknown agent name': expected exit 2 with message, got $code: $out" >&2; failures=$((failures + 1))
fi

fresh; rm "$work/t/CLAUDE.md"; mkdir -p "$work/t/.cursor/rules"; printf -- '---\nalwaysApply: true\n---\nx\n' > "$work/t/.cursor/rules/x.mdc"
expect pass "default detection with .cursor and no CLAUDE.md"
out="$(cd / && "$checker" --no-skills "$work/t" 2>&1)"
[[ "$out" == *"agents: codex, cursor;"* ]] || { echo "check-target case 'detects .cursor': got $out" >&2; failures=$((failures + 1)); }

fresh; rm "$work/t/CLAUDE.md"; printf 'x\n' > "$work/t/.cursorrules"
expect pass "default detection with .cursorrules and no CLAUDE.md"
out="$(cd / && "$checker" --no-skills "$work/t" 2>&1)"
[[ "$out" == *"agents: codex, cursor;"* ]] || { echo "check-target case 'detects .cursorrules': got $out" >&2; failures=$((failures + 1)); }

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

fresh; printf '\n<!-- template: keep one row when none -->\n' >> "$work/t/docs/agent/capability-map.md"; expect fail "template guidance left in a generated file"

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

fresh; python3 - "$work/t/docs/agent/capability-map.md" <<'PY3'
import sys
p = sys.argv[1]
s = open(p).read().replace("## Risk zones", "## Risky areas")
open(p, "w").write(s)
PY3
expect fail "capability map without Risk zones"

tools_map() {
  printf '# Workflow Integration Map\n\n## Tools (MCP servers and plugins)\n\n| Tool and version | Need | Scope | Config path | Status | Approved on |\n| --- | --- | --- | --- | --- | --- |\n| `x 1.0` | docs | project | `.mcp.json` | %s | 2026-11-21 |\n' "$1" > "$work/t/docs/agent/integrations.md"
}
fresh; tools_map "maybe"; expect fail "tools table with unknown status"
fresh; tools_map "approved, owner installs"; expect pass "tools table with allowed status"
fresh; tools_map '`declined`'; expect pass "tools table status in backticks"
fresh; printf '# Workflow Integration Map\n\n## Tools (MCP servers and plugins)\n\n| Tool | Need |\n| --- | --- |\n| x | maybe |\n' > "$work/t/docs/agent/integrations.md"
expect fail "tools table without Status column"
fresh; tools_map "bogus"; sed -i.bak 's/^| `x/  | `x/' "$work/t/docs/agent/integrations.md"; rm "$work/t/docs/agent/integrations.md.bak"
expect fail "indented tools row with unknown status"
fresh; printf '# Workflow Integration Map\n\n## Tools (MCP servers and plugins)\n\n| Tool and version | Need | Scope | Config path | Status | Approved on |\n| --- | --- | --- | --- | --- | --- |\n| `x 1.0` | a \\| b | project | n/a | declined | 2026-11-21 |\n' > "$work/t/docs/agent/integrations.md"
expect pass "escaped pipe in a tools cell"
fresh; printf '# Workflow Integration Map\n\n## Primary workflow owner\n\n- Tool or core playbook: none\n' > "$work/t/docs/agent/integrations.md"
expect pass "integration map without a tools section"
fresh; printf '# Workflow Integration Map\n\n## Tools (MCP servers and plugins)\n\n| Tool and version | Need | Scope | Config path | Status | Approved on |\n| --- | --- | --- | --- | --- | --- |\n' > "$work/t/docs/agent/integrations.md"
expect pass "tools table with no rows"
fresh; tools_map "declined (owner, 2026-11-21)"; expect fail "status with an owner suffix"

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

link_case() {
  local expected="$1" name="$2" line="$3"
  fresh; mkdir -p "$work/t/docs/agent/my dir"; printf '# A\n' > "$work/t/docs/agent/my dir/a.md"
  printf '\n%s\n' "$line" >> "$work/t/docs/agent/capability-map.md"
  expect "$expected" "$name"
}
link_case pass "link with spaces in angle brackets" '[a](<my dir/a.md>)'
link_case pass "percent-encoded link" '[a](my%20dir/a.md)'
link_case pass "root-absolute link" '[w](/docs/agent/workflow.md)'
link_case pass "valid anchor in another file" '[q](workflow.md#questions-and-checkpoints)'
link_case fail "broken anchor in another file" '[q](workflow.md#no-such-heading)'
link_case fail "broken same-file anchor" '[q](#no-such-heading)'
link_case pass "valid same-file anchor" '[q](#maintenance-triggers)'
fresh; printf '\n```\n[x](missing.md)\n```\n\nInline `[y](missing.md)` code.\n' >> "$work/t/docs/agent/capability-map.md"; expect pass "links inside code are ignored"

anchor_case() {
  local expected="$1" name="$2" doc="$3" line="$4"
  fresh; printf '%b' "$doc" > "$work/t/docs/agent/ref.md"
  printf '\n%s\n' "$line" >> "$work/t/docs/agent/capability-map.md"
  expect "$expected" "$name"
}
anchor_case pass "setext heading anchor" 'Installation\n============\n\nText\n\nUsage\n-----\n' '[i](ref.md#installation) [u](ref.md#usage)'
anchor_case pass "emphasis and html stripped from slug" '## _Emph_ text\n\n## <b>Bold</b> word\n' '[e](ref.md#emph-text) [b](ref.md#bold-word)'
anchor_case pass "github duplicate slug numbering" '## Dup\n\n## Dup\n\n## Dup-1\n' '[d](ref.md#dup-1-1)'
anchor_case pass "blockquote heading anchor" '> ## Quoted\n' '[q](ref.md#quoted)'
anchor_case pass "indented fence in list ignored" '- item\n\n   ```\n   [x](missing.md)\n   ```\n' '[r](ref.md)'
fresh; printf '\n- item\n\n   ```\n   [x](missing.md)\n   ```\n' >> "$work/t/docs/agent/capability-map.md"; expect pass "indented fence links ignored"
fresh; printf '\n````md\n```\n[x](missing.md)\n```\n````\n' >> "$work/t/docs/agent/capability-map.md"; expect pass "longer fence contains shorter fence"
fresh; printf '\n```\n[x](missing.md)\n' >> "$work/t/docs/agent/capability-map.md"; expect pass "unclosed fence runs to end of file"
fresh; mkdir -p "$work/t/docs/agent"; printf '# P\n' > "$work/t/docs/agent/foo(bar).md"; printf '\n[p](foo(bar).md)\n' >> "$work/t/docs/agent/capability-map.md"; expect pass "parentheses in link path"
fresh; printf '\n[w](workflow.md?raw=1)\n' >> "$work/t/docs/agent/capability-map.md"; expect pass "query string stripped"
fresh; printf '\n[![i](workflow.md)](missing.md)\n' >> "$work/t/docs/agent/capability-map.md"; expect fail "link around image is checked"

if (( failures > 0 )); then
  exit 1
fi
echo "check-target fixture tests passed."

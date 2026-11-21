#!/usr/bin/env bash
# Fixture tests for scripts/audit-ai-setup.sh. Each case builds a temporary target and HOME.
set -uo pipefail

playbook_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
audit="$playbook_root/scripts/audit-ai-setup.sh"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
failures=0
case_name=""
out=""
code=0

fresh() {
  case_name="$1"
  rm -rf "$work/t" "$work/home"
  mkdir -p "$work/t" "$work/home"
}

run_audit() {
  if out="$(cd / && HOME="$work/home" "$audit" "$@" "$work/t" 2>&1)"; then code=0; else code=$?; fi
}

fail() {
  echo "audit case '$case_name': $1" >&2
  echo "$out" >&2
  failures=$((failures + 1))
}

expect_code() { [[ "$code" == "$1" ]] || fail "expected exit $1, got $code"; }
expect_line() {
  local prefix
  prefix="$(printf '%s\t%s\t%s' "$1" "$2" "$3")"
  grep -qF -- "$prefix" <<<"$out" || fail "missing line: $1 $2 $3"
}
expect_no() { if grep -qF -- "$1" <<<"$out"; then fail "unexpected text: $1"; fi; }
expect_empty() { [[ -z "$out" ]] || fail "expected no output"; }

skill() {
  mkdir -p "$work/t/$1"
  printf -- '---\nname: %s\ndescription: d\n---\n%s\n' "$2" "$3" > "$work/t/$1/SKILL.md"
}

fresh "empty target"; run_audit; expect_code 0; expect_empty

fresh "mirrored playbook copies"; skill .agents/skills/x x body; skill .claude/skills/x x body
run_audit; expect_code 0; expect_line info skill-mirror skill:x

fresh "diverged copies"; skill .agents/skills/x x one; skill .claude/skills/x x two
run_audit; expect_code 1; expect_line warning skill-duplicate skill:x

fresh "frontmatter name wins over folder"; skill .agents/skills/z y one; skill .cursor/skills/z y two
run_audit; expect_line warning skill-duplicate skill:y

fresh "CLAUDE.md without import"; printf '# A\n' > "$work/t/AGENTS.md"; printf '# C\n' > "$work/t/CLAUDE.md"
run_audit; expect_code 1; expect_line warning claude-import-missing CLAUDE.md

fresh "CLAUDE.md with import"; printf '# A\n' > "$work/t/AGENTS.md"; printf '# C\n\n@AGENTS.md\n' > "$work/t/CLAUDE.md"
run_audit; expect_code 0; expect_no claude-import-missing

fresh "import only inside a fence"; printf '# A\n' > "$work/t/AGENTS.md"; printf '```\n@AGENTS.md\n```\n' > "$work/t/CLAUDE.md"
run_audit; expect_line warning claude-import-missing CLAUDE.md

fresh "CLAUDE.md symlink"; printf '# A\n' > "$work/t/AGENTS.md"; ln -s AGENTS.md "$work/t/CLAUDE.md"
run_audit; expect_no claude-import-missing

fresh "instruction sources"; printf 'x\n' > "$work/t/.cursorrules"; mkdir -p "$work/t/.github"; printf 'x\n' > "$work/t/.github/copilot-instructions.md"
run_audit; expect_code 0; expect_line info instruction-sources .cursorrules; expect_line info instruction-sources .github/copilot-instructions.md

fresh "broken reference"; printf '[a](missing.md) [b](https://x.y) [c](#anchor)\n' > "$work/t/AGENTS.md"
run_audit; expect_code 1; expect_line warning broken-reference AGENTS.md
[[ "$(grep -c "broken-reference" <<<"$out")" == 1 ]] || fail "expected exactly one broken-reference"
grep -qF "missing.md" <<<"$out" || fail "detail should name missing.md"

mcp_json() {
  mkdir -p "$(dirname "$work/t/$1")"
  printf '{"mcpServers":{"gh":{"command":"npx","args":["a@1"]%s}}}\n' "$2" > "$work/t/$1"
}
codex_toml() {
  mkdir -p "$work/t/.codex"
  printf '[mcp_servers.gh]\ncommand = "npx"\nargs = ["%s"]\n%s' "$1" "$2" > "$work/t/.codex/config.toml"
}

fresh "identical MCP for two agents"; mcp_json .mcp.json ""; codex_toml "a@1" ""
run_audit; expect_code 0; expect_line info mcp-duplicate mcp:gh

fresh "drifted MCP"; mcp_json .mcp.json ""; codex_toml "a@2" ""
run_audit; expect_code 1; expect_line warning mcp-duplicate mcp:gh

fresh "literal secret in JSON"; mcp_json .mcp.json ',"env":{"GITHUB_TOKEN":"ghp_secretvalue"}'
run_audit; expect_code 1; expect_line warning mcp-literal-secret mcp:gh; expect_no ghp_secretvalue

fresh "references are not secrets"; mcp_json .mcp.json ',"env":{"GITHUB_TOKEN":"${GITHUB_TOKEN}","API_KEY":"${env:API_KEY}"}'
run_audit; expect_no mcp-literal-secret

fresh "literal secret in TOML"; codex_toml "a@1" '[mcp_servers.gh.env]
API_KEY = "abc123"
'
run_audit; expect_code 1; expect_line warning mcp-literal-secret mcp:gh; expect_no abc123

fresh "hooks"; mkdir -p "$work/t/.claude"
printf '{"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"x.sh"}]}]}}\n' > "$work/t/.claude/settings.json"
run_audit; expect_code 0; expect_line info hooks .claude/settings.json; grep -qF "PreToolUse: x.sh" <<<"$out" || fail "hook detail"

fresh "methodology marker"; mkdir -p "$work/t/.specify"
run_audit; expect_code 0; expect_line info methodology-tools .specify/

fresh "unreadable JSON"; printf '{not json\n' > "$work/t/.mcp.json"
run_audit; expect_code 0; expect_line info unreadable .mcp.json

fresh "stable order"; skill .agents/skills/b b 1; skill .claude/skills/b b 2; skill .agents/skills/a a 1; skill .cursor/skills/a a 2
printf 'x\n' > "$work/t/.cursorrules"
run_audit; first="$out"; run_audit; [[ "$first" == "$out" ]] || fail "output differs between runs"

fresh "unknown option"; run_audit --bogus; expect_code 2

home_skill() {
  mkdir -p "$work/home/$1"
  printf -- '---\nname: %s\ndescription: d\n---\n%s\n' "$2" "$3" > "$work/home/$1/SKILL.md"
}

fresh "user skill ignored without --global"; skill .agents/skills/x x repo; home_skill .claude/skills/x x user
run_audit; expect_code 0; expect_no skill-shadow

fresh "user skill shadows repo skill"; skill .agents/skills/x x repo; home_skill .claude/skills/x x user
run_audit --global; expect_code 1; expect_line warning skill-shadow skill:x
grep -qF "user-level:claude-skills:x" <<<"$out" || fail "detail should name user-level:claude-skills:x"
expect_no "$work/home"

fresh "playbook skill at user level"; mkdir -p "$work/t/.agents/skills/x" "$work/home/.claude/skills/x"
printf -- '---\nname: x\n---\n<!-- agent-playbook rev a -->\nbody\n' > "$work/t/.agents/skills/x/SKILL.md"
printf -- '---\nname: x\n---\n<!-- agent-playbook rev b -->\nbody\n' > "$work/home/.claude/skills/x/SKILL.md"
run_audit --global; expect_code 0; expect_line info skill-mirror skill:x

plugin() {
  mkdir -p "$work/home/.claude/plugins" "$work/home/pc/p/skills/review-task"
  printf '{"enabledPlugins":{"p@m":%s}}\n' "$1" > "$work/home/.claude/settings.json"
  printf '{"version":2,"plugins":{"p@m":[{"installPath":"%s"}]}}\n' "$work/home/pc/p" > "$work/home/.claude/plugins/installed_plugins.json"
  printf -- '---\nname: review-task\n---\nplugin\n' > "$work/home/pc/p/skills/review-task/SKILL.md"
}

fresh "enabled plugin skill shadows repo skill"; skill .agents/skills/review-task review-task repo; plugin true
run_audit --global; expect_code 1; expect_line warning skill-shadow skill:review-task
grep -qF "user-level:claude-plugin:p@m" <<<"$out" || fail "detail should name the plugin"; expect_no "$work/home"

fresh "disabled plugin ignored"; skill .agents/skills/review-task review-task repo; plugin false
run_audit --global; expect_code 0; expect_no skill-shadow

fresh "no installed_plugins.json"; skill .agents/skills/review-task review-task repo; plugin true; rm "$work/home/.claude/plugins/installed_plugins.json"
run_audit --global; expect_code 0; expect_no skill-shadow

fresh "user MCP drift"; mcp_json .cursor/mcp.json ""; mkdir -p "$work/home/.cursor"
printf '{"mcpServers":{"gh":{"command":"npx","args":["a@2"]}}}\n' > "$work/home/.cursor/mcp.json"
run_audit --global; expect_code 1; expect_line warning mcp-duplicate mcp:gh; expect_no "$work/home"

fresh "user superpowers plugin"; mkdir -p "$work/home/.claude"; printf '{"enabledPlugins":{"superpowers@claude-plugins-official":true}}\n' > "$work/home/.claude/settings.json"
run_audit --global; expect_code 0; expect_line info methodology-tools user-level:claude-plugin:superpowers@claude-plugins-official

decisions() {
  mkdir -p "$work/t/docs/agent"
  printf '# Map\n\n## AI setup audit\n\nUser-level audit: declined (owner, 2026-11-21)\n\n| Kind | Location | Decision | Source |\n| --- | --- | --- | --- |\n| skill-duplicate | %s | %s | owner, 2026-11-21 |\n' "$1" "$2" > "$work/t/docs/agent/integrations.md"
}

fresh "accepted finding"; skill .agents/skills/x x one; skill .claude/skills/x x two; decisions skill:x keep
run_audit; expect_code 0; expect_line info skill-duplicate skill:x; grep -qF "(accepted)" <<<"$out" || fail "accepted marker"

fresh "decision for another location"; skill .agents/skills/x x one; skill .claude/skills/x x two; decisions skill:other keep
run_audit; expect_code 1; expect_line warning skill-duplicate skill:x

fresh "decision other than keep"; skill .agents/skills/x x one; skill .claude/skills/x x two; decisions skill:x merge
run_audit; expect_code 1; expect_line warning skill-duplicate skill:x

fresh "no code from the target runs"; printf 'open("%s/PWNED", "w").write("x")\nfrom json import *\n' "$work" > "$work/t/json.py"; rm -f "$work/PWNED"
if out="$(cd "$work/t" && HOME="$work/home" "$audit" . 2>&1)"; then code=0; else code=$?; fi
[[ ! -e "$work/PWNED" ]] || fail "target json.py was executed"; expect_code 0

for body in '[1]' '{"mcpServers":[1]}' '{"mcpServers":{"gh":{"command":"npx","env":["A"]}}}' '{"mcpServers":{"gh":{"command":{"x":1},"args":[{"y":2}]}}}'; do
  fresh "odd JSON shape $body"; printf '%s\n' "$body" > "$work/t/.mcp.json"; printf '%s\n' "$body" > "$work/t/.cursor-mcp.tmp"
  mkdir -p "$work/t/.cursor"; mv "$work/t/.cursor-mcp.tmp" "$work/t/.cursor/mcp.json"
  run_audit; [[ "$code" == 0 || "$code" == 1 ]] || fail "exit $code"; expect_no Traceback
done
for body in '[]' '{"enabledPlugins":[1],"hooks":{"PreToolUse":["x"]}}' '{"hooks":[1]}'; do
  fresh "odd settings shape $body"; mkdir -p "$work/t/.claude" "$work/home/.claude"; printf '%s\n' "$body" > "$work/t/.claude/settings.json"; printf '%s\n' "$body" > "$work/home/.claude/settings.json"
  run_audit --global; expect_code 0; expect_no Traceback
done

fresh "unreadable files"; printf '# A\n' > "$work/t/AGENTS.md"; printf '{}\n' > "$work/t/.mcp.json"; mkdir -p "$work/home/.codex"; printf '[mcp_servers.a]\n' > "$work/home/.codex/config.toml"
chmod 000 "$work/t/AGENTS.md" "$work/t/.mcp.json" "$work/home/.codex/config.toml"
run_audit --global; chmod 644 "$work/t/AGENTS.md" "$work/t/.mcp.json" "$work/home/.codex/config.toml"
expect_no Traceback; expect_no "$work/home"; expect_line info unreadable .mcp.json; expect_line info unreadable user-level:codex-mcp

fresh "dangling CLAUDE.md symlink"; printf '# A\n' > "$work/t/AGENTS.md"; ln -s nowhere.md "$work/t/CLAUDE.md"
run_audit; expect_no Traceback

fresh "inline TOML env secret"; mkdir -p "$work/t/.codex"; printf '[mcp_servers.gh]\ncommand = "npx"\nenv = { "API_KEY" = "sk-live-123" }\n' > "$work/t/.codex/config.toml"
run_audit; expect_line warning mcp-literal-secret mcp:gh; expect_no sk-live-123

fresh "multi-line and single-quoted TOML args"; mcp_json .mcp.json ""; mkdir -p "$work/t/.codex"
printf "[mcp_servers.\"gh\"]\ncommand = 'npx'\nargs = [\n  'a@1',\n]\n" > "$work/t/.codex/config.toml"
run_audit; expect_code 0; expect_line info mcp-duplicate mcp:gh

fresh "malformed TOML"; mkdir -p "$work/t/.codex"; printf '[mcp_servers.gh]\nargs = [ "a@1"\n' > "$work/t/.codex/config.toml"
run_audit; expect_no Traceback; expect_line info unreadable .codex/config.toml

fresh "hook commands are not printed verbatim"; mkdir -p "$work/t/.claude"
printf '{"hooks":{"Stop":[{"hooks":[{"type":"command","command":"/Users/someone/bin/notify.sh --token abc123\\twarning\\tfake"}]}]}}\n' > "$work/t/.claude/settings.local.json"
run_audit; expect_line info hooks .claude/settings.local.json; expect_no abc123; expect_no /Users/someone; expect_no "fake"

fresh "bearer reference is not a secret"; mcp_json .mcp.json ',"headers":{"Authorization":"Bearer ${GH_TOKEN}"}'
run_audit; expect_no mcp-literal-secret

fresh "target under a build directory"; rm -rf "$work/t"; mkdir -p "$work/build/t"; ln -s "$work/build/t" "$work/t"
mkdir -p "$work/build/t/.agents/skills/x"; printf -- '---\nname: x\n---\n[a](missing.md)\n' > "$work/build/t/.agents/skills/x/SKILL.md"
if out="$(cd / && HOME="$work/home" "$audit" "$work/build/t" 2>&1)"; then code=0; else code=$?; fi
expect_line warning broken-reference .agents/skills/x/SKILL.md; rm -rf "$work/build"

fresh "plugin without installPath"; skill .agents/skills/review-task review-task repo; mkdir -p "$work/home/.claude/plugins"
printf '{"enabledPlugins":{"p@m":true}}\n' > "$work/home/.claude/settings.json"; printf '{"plugins":{"p@m":[{"version":"1"}]}}\n' > "$work/home/.claude/plugins/installed_plugins.json"
mkdir -p "$work/skills/review-task"; printf -- '---\nname: review-task\n---\ncwd\n' > "$work/skills/review-task/SKILL.md"
if out="$(cd "$work" && HOME="$work/home" "$audit" --global "$work/t" 2>&1)"; then code=0; else code=$?; fi
expect_code 0; expect_no skill-shadow; rm -rf "$work/skills"

fresh "indented fence toggles like check-target"; printf '# A\n' > "$work/t/AGENTS.md"; printf '    ```\n@AGENTS.md\n    ```\n' > "$work/t/CLAUDE.md"
run_audit; expect_line warning claude-import-missing CLAUDE.md

fresh "two imports"; printf '# A\n' > "$work/t/AGENTS.md"; printf '@AGENTS.md\n@AGENTS.md\n' > "$work/t/CLAUDE.md"
run_audit; expect_code 1; expect_line warning claude-import-missing CLAUDE.md; grep -qF "2 times" <<<"$out" || fail "detail should give the count"

fresh "playbook header with a local-path source"; mkdir -p "$work/t/.agents/skills/x" "$work/home/.claude/skills/x"
printf -- '---\nname: x\n---\n<!-- Generated by the Agent Playbook. Source: ~/src/pb. Revision: a. -->\nbody\n' > "$work/t/.agents/skills/x/SKILL.md"
printf -- '---\nname: x\n---\n<!-- Generated by the Agent Playbook. Source: /opt/pb. Revision: b. -->\nbody\n' > "$work/home/.claude/skills/x/SKILL.md"
run_audit --global; expect_code 0; expect_line info skill-mirror skill:x

fresh "CRLF frontmatter name"; mkdir -p "$work/t/.agents/skills/folder" "$work/t/.claude/skills/other"
printf -- '---\r\nname: crlf\r\n---\r\none\r\n' > "$work/t/.agents/skills/folder/SKILL.md"; printf -- '---\nname: crlf\n---\ntwo\n' > "$work/t/.claude/skills/other/SKILL.md"
run_audit; expect_line warning skill-duplicate skill:crlf

fresh "two installs of one plugin"; mkdir -p "$work/home/.claude/plugins" "$work/home/pc/v1/skills/s" "$work/home/pc/v2/skills/s"
printf '{"enabledPlugins":{"p@m":true}}\n' > "$work/home/.claude/settings.json"
printf '{"plugins":{"p@m":[{"installPath":"%s","version":"1.0"},{"installPath":"%s","version":"2.0"}]}}\n' "$work/home/pc/v1" "$work/home/pc/v2" > "$work/home/.claude/plugins/installed_plugins.json"
printf -- '---\nname: s\n---\none\n' > "$work/home/pc/v1/skills/s/SKILL.md"; printf -- '---\nname: s\n---\ntwo\n' > "$work/home/pc/v2/skills/s/SKILL.md"
run_audit --global; expect_line warning skill-duplicate skill:s
grep -qF "user-level:claude-plugin:p@m@1.0" <<<"$out" && grep -qF "user-level:claude-plugin:p@m@2.0" <<<"$out" || fail "detail should name both installs"

fresh "docs/agent ignored by git"; git -C "$work/t" init -q; printf 'docs/\n' > "$work/t/.gitignore"
run_audit; expect_code 1; expect_line warning agent-docs-ignored docs/agent/

fresh "docs/agent re-included"; git -C "$work/t" init -q; printf 'docs/*\n!docs/agent/\n' > "$work/t/.gitignore"
run_audit; expect_no agent-docs-ignored

fresh "docs/agent tracked despite ignore"; git -C "$work/t" init -q; mkdir -p "$work/t/docs/agent"; printf 'x\n' > "$work/t/docs/agent/workflow.md"
git -C "$work/t" add docs/agent/workflow.md; printf 'docs/\n' > "$work/t/.gitignore"
run_audit; expect_no agent-docs-ignored

fresh "not a git repository"; printf 'docs/\n' > "$work/t/.gitignore"
run_audit; expect_no agent-docs-ignored

if [[ "$failures" -ne 0 ]]; then
  echo "audit fixture tests: $failures failure(s)" >&2
  exit 1
fi
echo "audit fixture tests passed."

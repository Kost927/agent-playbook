#!/usr/bin/env bash
# Check an initialized target repository against the playbook templates. Never writes.
#
# Usage: scripts/check-target.sh [--agents claude,codex] [--no-skills] <target-dir>
#   --agents     agents the target was initialized for. Default: Codex always; Claude Code
#                when the target root has CLAUDE.md or .claude/.
#   --no-skills  skip the workflow-skill checks (for fixtures that omit skill copies).
set -euo pipefail

agents=""
skills=1
while [[ $# -gt 1 ]]; do
  case "$1" in
    --agents) agents="$2"; shift 2 ;;
    --no-skills) skills=0; shift ;;
    *) break ;;
  esac
done
if [[ $# -ne 1 || ! -d "$1" ]]; then
  echo "usage: $0 [--agents claude,codex] [--no-skills] <target-dir>" >&2
  exit 2
fi

playbook_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target_root="$(cd "$1" && pwd)"

python3 - "$playbook_root" "$target_root" "$agents" "$skills" <<'PY'
import os
import re
import sys
from pathlib import Path

playbook, target = Path(sys.argv[1]), Path(sys.argv[2])
agents_arg, check_skills = sys.argv[3], sys.argv[4] == "1"
errors = []
START, END = "<!-- agent-playbook:start -->", "<!-- agent-playbook:end -->"
PLACEHOLDER = re.compile(r"`<[^`>]+>`")
SKIPPED_DIRS = {".git", "node_modules", "vendor", "third_party", ".venv", "venv", "dist", "build", "__pycache__", ".tox"}
SKILL_NAMES = sorted(p.parent.name for p in (playbook / "skills").glob("*/SKILL.md"))

if agents_arg:
    agents = {a.strip() for a in agents_arg.split(",") if a.strip()}
else:
    agents = {"codex"} | ({"claude"} if (target / "CLAUDE.md").exists() or (target / ".claude").exists() else set())


def rel(path):
    return path.relative_to(target).as_posix()


def read(path):
    return path.read_text(encoding="utf-8", errors="replace")


def find(name):
    for directory, subdirs, files in os.walk(target):
        subdirs[:] = [d for d in subdirs if d not in SKIPPED_DIRS]
        if name in files:
            yield Path(directory) / name


def managed_lines(text):
    if START not in text or END not in text:
        return None
    return text.split(START, 1)[1].split(END, 1)[0].strip("\n").splitlines()


def line_pattern(template_line):
    parts = PLACEHOLDER.split(template_line)
    return re.compile("^" + "`[^`]+`".join(re.escape(part) for part in parts) + "$")


def check_block(path, template_name):
    template = managed_lines(read(playbook / "templates" / template_name))
    actual = managed_lines(read(path))
    if actual is None:
        errors.append(f"{rel(path)}: missing agent-playbook markers")
        return
    if len(actual) != len(template):
        errors.append(f"{rel(path)}: managed block has {len(actual)} lines, template {template_name} has {len(template)}")
        return
    for number, (want, got) in enumerate(zip(template, actual), 1):
        if not line_pattern(want).match(got):
            errors.append(f"{rel(path)}: managed line {number} differs from {template_name}: {got!r}")


def check_claude(claude, agents_file):
    if claude.is_symlink():
        if claude.resolve() != agents_file.resolve():
            errors.append(f"{rel(claude)}: symlink does not point to its sibling AGENTS.md")
    elif not claude.exists():
        errors.append(f"{rel(claude)}: missing sibling of {rel(agents_file)}")
    else:
        check_block(claude, "claude-entry.md")
        imports, in_fence = 0, False
        for line in read(claude).splitlines():
            if line.lstrip().startswith(("```", "~~~")):
                in_fence = not in_fence
            elif not in_fence and line.strip() == "@AGENTS.md":
                imports += 1
        if imports != 1:
            errors.append(f"{rel(claude)}: must import @AGENTS.md exactly once outside code fences, found {imports}")


# Entry points. The root AGENTS.md is always managed and must match the template exactly.
# Nested AGENTS.md files are managed only when they carry markers; they inherit root policy,
# so they are checked for placeholders and their CLAUDE.md sibling, not compared with the template.
root_agents = target / "AGENTS.md"
if not root_agents.exists():
    errors.append("AGENTS.md: missing")
else:
    check_block(root_agents, "agents-entry.md")
managed_agents = [root_agents] if root_agents.exists() else []
managed_agents += [p for p in find("AGENTS.md") if p != root_agents and START in read(p)]
if "claude" in agents:
    for agents_file in managed_agents:
        check_claude(agents_file.with_name("CLAUDE.md"), agents_file)

# Local workflow documents.
docs = target / "docs" / "agent"
for name in ("workflow.md", "project-map.md", "capability-map.md"):
    if not (docs / name).exists():
        errors.append(f"docs/agent/{name}: missing")
if (docs / "workflow.md").exists():
    check_block(docs / "workflow.md", "local-workflow.md")

# Placeholders and links in generated files.
entry_files = []
for agents_file in managed_agents:
    entry_files += [agents_file, agents_file.with_name("CLAUDE.md")]
generated = [p for p in [*entry_files, *sorted(docs.glob("*.md"))] if p.exists() and not p.is_symlink()]
link = re.compile(r"(?<!!)\[[^]]+\]\(([^)]+)\)")
for path in generated:
    text = read(path)
    for match in PLACEHOLDER.findall(text):
        errors.append(f"{rel(path)}: unfilled placeholder {match}")
    for raw in link.findall(text):
        href = raw.strip().split(maxsplit=1)[0].strip("<>")
        if href.startswith(("http://", "https://", "mailto:", "#")):
            continue
        local = href.split("#", 1)[0]
        if local and not (path.parent / local).exists():
            errors.append(f"{rel(path)}: missing link target {href}")

# Workflow skills.
if check_skills:
    locations = [".agents/skills"] + ([".claude/skills"] if "claude" in agents else [])
    for name in SKILL_NAMES:
        canonical = target / ".agents" / "skills" / name / "SKILL.md"
        for location in locations:
            if not (target / location / name / "SKILL.md").exists():
                errors.append(f"{location}/{name}/SKILL.md: missing")
        copy = target / ".claude" / "skills" / name / "SKILL.md"
        if canonical.exists() and copy.exists() and canonical.read_bytes() != copy.read_bytes():
            errors.append(f"{rel(copy)}: differs from {rel(canonical)}")
for copy in sorted((target / ".claude" / "skills").glob("*/SKILL.md")):
    canonical = target / ".agents" / "skills" / copy.parent.name / "SKILL.md"
    if not canonical.exists():
        errors.append(f"{rel(copy)}: no canonical copy in .agents/skills/")
    elif canonical.read_bytes() != copy.read_bytes():
        errors.append(f"{rel(copy)}: differs from {rel(canonical)}")
errors = list(dict.fromkeys(errors))

if errors:
    print("\n".join(errors), file=sys.stderr)
    raise SystemExit(1)
print(f"Target check passed: {target} (agents: {', '.join(sorted(agents))}; skills: {'checked' if check_skills else 'skipped'})")
PY

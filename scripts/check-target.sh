#!/usr/bin/env bash
# Check an initialized target repository against the playbook templates. Never writes.
# Usage: scripts/check-target.sh <target-dir>
set -euo pipefail

if [[ $# -ne 1 || ! -d "$1" ]]; then
  echo "usage: $0 <target-dir>" >&2
  exit 2
fi

playbook_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target_root="$(cd "$1" && pwd)"

python3 - "$playbook_root" "$target_root" <<'PY'
import re
import sys
from pathlib import Path

playbook, target = Path(sys.argv[1]), Path(sys.argv[2])
errors = []
START, END = "<!-- agent-playbook:start -->", "<!-- agent-playbook:end -->"
PLACEHOLDER = re.compile(r"`<[^`>]+>`")


def rel(path):
    return path.relative_to(target).as_posix()


def managed_lines(text):
    if START not in text or END not in text:
        return None
    return text.split(START, 1)[1].split(END, 1)[0].strip("\n").splitlines()


def line_pattern(template_line):
    parts = PLACEHOLDER.split(template_line)
    return re.compile("^" + "`[^`]+`".join(re.escape(part) for part in parts) + "$")


def check_block(path, template_name):
    template = managed_lines((playbook / "templates" / template_name).read_text(encoding="utf-8"))
    actual = managed_lines(path.read_text(encoding="utf-8"))
    if actual is None:
        errors.append(f"{rel(path)}: missing agent-playbook markers")
        return
    if len(actual) != len(template):
        errors.append(f"{rel(path)}: managed block has {len(actual)} lines, template {template_name} has {len(template)}")
        return
    for number, (want, got) in enumerate(zip(template, actual), 1):
        if not line_pattern(want).match(got):
            errors.append(f"{rel(path)}: managed line {number} differs from {template_name}: {got!r}")


# Entry points.
agents_files = [p for p in target.rglob("AGENTS.md") if START in p.read_text(encoding="utf-8")]
if not (target / "AGENTS.md").exists():
    errors.append("AGENTS.md: missing")
claude_configured = any(target.rglob("CLAUDE.md")) or (target / ".claude").exists()
for agents in agents_files:
    check_block(agents, "agents-entry.md")
    claude = agents.with_name("CLAUDE.md")
    if not claude_configured:
        continue
    if claude.is_symlink():
        if claude.resolve() != agents.resolve():
            errors.append(f"{rel(claude)}: symlink does not point to its sibling AGENTS.md")
    elif not claude.exists():
        errors.append(f"{rel(claude)}: missing sibling of {rel(agents)}")
    else:
        imports = [line for line in claude.read_text(encoding="utf-8").splitlines() if line.strip() == "@AGENTS.md"]
        if len(imports) != 1:
            errors.append(f"{rel(claude)}: must import @AGENTS.md exactly once, found {len(imports)}")

# Local workflow documents.
docs = target / "docs" / "agent"
for name in ("workflow.md", "project-map.md", "capability-map.md"):
    if not (docs / name).exists():
        errors.append(f"docs/agent/{name}: missing")
if (docs / "workflow.md").exists():
    check_block(docs / "workflow.md", "local-workflow.md")

# Placeholders and links in generated files.
generated = [p for p in [target / "AGENTS.md", target / "CLAUDE.md", *sorted(docs.glob("*.md"))] if p.exists() and not p.is_symlink()]
link = re.compile(r"(?<!!)\[[^]]+\]\(([^)]+)\)")
for path in generated:
    text = path.read_text(encoding="utf-8")
    for match in PLACEHOLDER.findall(text):
        errors.append(f"{rel(path)}: unfilled placeholder {match}")
    for raw in link.findall(text):
        href = raw.strip().split(maxsplit=1)[0].strip("<>")
        if href.startswith(("http://", "https://", "mailto:", "#")):
            continue
        local = href.split("#", 1)[0]
        if local and not (path.parent / local).exists():
            errors.append(f"{rel(path)}: missing link target {href}")

# Skill copies.
for claude_skill in sorted((target / ".claude" / "skills").glob("*/SKILL.md")):
    source = target / ".agents" / "skills" / claude_skill.parent.name / "SKILL.md"
    if not source.exists():
        errors.append(f"{rel(claude_skill)}: no canonical copy in .agents/skills/")
    elif source.read_bytes() != claude_skill.read_bytes():
        errors.append(f"{rel(claude_skill)}: differs from {rel(source)}")

if errors:
    print("\n".join(errors), file=sys.stderr)
    raise SystemExit(1)
print(f"Target check passed: {target}")
PY

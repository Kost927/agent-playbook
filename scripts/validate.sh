#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repository_root"

required_files=(
  README.md
  bootstrap.md
  greenfield.md
  workflow.md
  integrations.md
  docs/flow.html
  skills/initialize-agent-workflow/SKILL.md
  skills/execute-task-workflow/SKILL.md
  skills/review-task/SKILL.md
  roles/implementer.md
  roles/reviewer.md
  profiles/capability-workstreams.md
  templates/local-workflow.md
  templates/project-map.md
  templates/capability-map.md
  templates/integration-map.md
  templates/specification.md
  templates/task.md
  templates/handoff.md
  templates/review-report.md
  templates/product-brief.md
  templates/adr.md
)

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "Missing required file: $file" >&2
    exit 1
  fi
done

python3 - "$repository_root" <<'PY'
import re
import sys
from pathlib import Path
from urllib.parse import unquote

root = Path(sys.argv[1])
link_pattern = re.compile(r"(?<!!)\[[^]]+\]\(([^)]+)\)")
errors = []

for document in sorted(root.rglob("*.md")):
    if ".git" in document.parts:
        continue
    text = document.read_text(encoding="utf-8")
    for raw_target in link_pattern.findall(text):
        target = raw_target.strip().split(maxsplit=1)[0].strip("<>")
        if target.startswith(("http://", "https://", "mailto:", "#")):
            continue
        path_text = unquote(target.split("#", 1)[0])
        if not path_text:
            continue
        resolved = (document.parent / path_text).resolve()
        try:
            resolved.relative_to(root.resolve())
        except ValueError:
            errors.append(f"{document.relative_to(root)}: link escapes repository: {target}")
            continue
        if not resolved.exists():
            errors.append(f"{document.relative_to(root)}: missing link target: {target}")

for skill_file in sorted((root / "skills").glob("*/SKILL.md")):
    text = skill_file.read_text(encoding="utf-8")
    frontmatter = re.match(r"\A---\n(.*?)\n---\n", text, re.DOTALL)
    if not frontmatter:
        errors.append(f"{skill_file.relative_to(root)}: missing YAML frontmatter")
        continue
    fields = {}
    for line in frontmatter.group(1).splitlines():
        if ":" in line and not line.startswith((" ", "\t")):
            key, value = line.split(":", 1)
            fields[key.strip()] = value.strip()
    expected_name = skill_file.parent.name
    if fields.get("name") != expected_name:
        errors.append(
            f"{skill_file.relative_to(root)}: name must match folder {expected_name!r}"
        )
    if not fields.get("description"):
        errors.append(f"{skill_file.relative_to(root)}: missing description")
    if re.search(r"TODO|PLACEHOLDER|Example Skill|\[TBD\]", text, re.IGNORECASE):
        errors.append(f"{skill_file.relative_to(root)}: unfinished scaffold placeholder")

if "(greenfield.md)" not in (root / "bootstrap.md").read_text(encoding="utf-8"):
    errors.append("bootstrap.md: must link greenfield.md")

for map_name in ("templates/project-map.md", "templates/capability-map.md"):
    if "planned | verified" not in (root / map_name).read_text(encoding="utf-8"):
        errors.append(f"{map_name}: missing planned/verified status")

greenfield_rules = {
    "bootstrap.md": ["match the stack ADR", "do not count against greenfield", "continue from step 3", "handled by the greenfield interview", "Re-check `proposed` ADRs", "Do not silently delete"],
    "greenfield.md": ["do not count against greenfield", "docs/agent/tasks/", "ADR-0001 accepted", "bootstrap update mode has been run"],
    "templates/local-workflow.md": ["docs/agent/tasks/"],
    "templates/project-map.md": ["planned | verified | unknown"],
    "templates/capability-map.md": ["planned | verified | unknown", "traced to the product brief"],
}
for rule_file, phrases in greenfield_rules.items():
    rule_text = (root / rule_file).read_text(encoding="utf-8")
    for phrase in phrases:
        if phrase not in rule_text:
            errors.append(f"{rule_file}: missing greenfield rule: {phrase}")

question_rules = {
    "workflow.md": ["## Questions and checkpoints", "look first", "Lead with your recommendation", "one at a time", "list assumptions in the final report", "wait for approval", "new checkpoint", "Decisions table", "before writing tests or implementation code", "stop editing", "Then run the Standard/Full checkpoint"],
    "templates/specification.md": ["## Assumptions"],
    "templates/local-workflow.md": ["Questions and checkpoints", "new checkpoint", "wait for approval", "look first", "stop editing", "affected units", "before writing tests or implementation code"],
    "skills/execute-task-workflow/SKILL.md": ["Questions and checkpoints", "checkpoint", "docs/agent/workflow.md"],
    "roles/implementer.md": ["Questions and checkpoints", "checkpoint"],
}
for rule_file, phrases in question_rules.items():
    rule_text = (root / rule_file).read_text(encoding="utf-8")
    for phrase in phrases:
        if phrase not in rule_text:
            errors.append(f"{rule_file}: missing question rule: {phrase}")

if errors:
    print("\n".join(errors), file=sys.stderr)
    raise SystemExit(1)

print("Validated required files, skills, and local Markdown link targets.")
PY

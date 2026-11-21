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
  templates/agents-entry.md
  templates/claude-entry.md
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
    "greenfield.md": ["do not count against greenfield", "docs/agent/tasks/", "stack ADR being accepted", "bootstrap update mode has been run"],
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

discovery_rules = {
    "bootstrap.md": ["@AGENTS.md", "only when other content of the same file changes", "sibling", "is a symlink to `AGENTS.md`", "every managed `AGENTS.md`", "points to `docs/agent/workflow.md`", "always records the pinned playbook revision"],
    "templates/project-map.md": ["only when this file's facts change"],
    "templates/capability-map.md": ["only when this file's facts change"],
    "templates/integration-map.md": ["only when this file's facts change"],
    "templates/local-workflow.md": ["only when this file's facts change", "always tracks the pinned playbook"],
    "skills/initialize-agent-workflow/SKILL.md": [".claude/skills/", "byte-identical"],
    "README.md": [".claude/skills/", "@AGENTS.md"],
}
discovery_rules["bootstrap.md"] += [".claude/skills/<skill-name>/SKILL.md", "byte-identical", "symlink"]
for rule_file, phrases in discovery_rules.items():
    rule_text = (root / rule_file).read_text(encoding="utf-8")
    for phrase in phrases:
        if phrase not in rule_text:
            errors.append(f"{rule_file}: missing discovery rule: {phrase}")

trial_rules = {
    "bootstrap.md": ["directory the user names", "already present", "templates/agents-entry.md", "target repository `HEAD`", "URL or local path"],
    "templates/project-map.md": ["none found"],
    "profiles/capability-workstreams.md": ["escalation trigger"],
    "README.md": ["for Claude Code and Codex"],
}
for rule_file, phrases in trial_rules.items():
    rule_text = (root / rule_file).read_text(encoding="utf-8")
    for phrase in phrases:
        if phrase not in rule_text:
            errors.append(f"{rule_file}: missing trial rule: {phrase}")
if "<TASK_ARTIFACTS_PATH>" in (root / "templates/local-workflow.md").read_text(encoding="utf-8"):
    errors.append("templates/local-workflow.md: TASK_ARTIFACTS_PATH placeholder must be replaced by the default path")

context_rules = {
    "workflow.md": ["## Context and models", "artifacts on disk", "fresh session", "context isolation", "implementer's narrative", "deep", "different model family", "session default", "record the approval", "On Standard and Full routes, tests come from a different context"],
    "templates/local-workflow.md": ["Context and models", "fresh session", "artifacts on disk", "different model family", "| Role | Tier | Model |", "never guess model names", "return to the artifacts", "record the approval"],
    "bootstrap.md": ["model roster", "keep the repository's model roster"],
    "templates/review-report.md": ["Implementer: ", "Reviewer: "],
    "templates/handoff.md": ["Start a fresh session"],
    "roles/reviewer.md": ["Context and models"],
    "roles/implementer.md": ["Context and models"],
    "skills/review-task/SKILL.md": ["Context and models"],
    "skills/execute-task-workflow/SKILL.md": ["Context and models"],
}
local_template = (root / "templates/local-workflow.md").read_text(encoding="utf-8")
if local_template.find("| Role | Tier | Model |") < local_template.find("<!-- agent-playbook:end -->"):
    errors.append("templates/local-workflow.md: model roster must be repository-owned, below the managed block")
for rule_file, phrases in context_rules.items():
    rule_text = (root / rule_file).read_text(encoding="utf-8")
    for phrase in phrases:
        if phrase not in rule_text:
            errors.append(f"{rule_file}: missing context rule: {phrase}")

if errors:
    print("\n".join(errors), file=sys.stderr)
    raise SystemExit(1)

print("Validated required files, skills, and local Markdown link targets.")
PY

example_root="$repository_root/examples/task-tracker"
if ! example_output="$(cd "$example_root" && PYTHONPATH=src python3 -m unittest discover -s tests -t . 2>&1)"; then
  echo "$example_output" >&2
  echo "example tests failed (examples/task-tracker)" >&2
  exit 1
fi
echo "Example tests passed."

if [[ ! -f "$example_root/TRIAL.md" ]]; then
  echo "Missing example file: examples/task-tracker/TRIAL.md" >&2
  exit 1
fi
"$repository_root/scripts/check-target.sh" --no-skills --agents claude,codex "$example_root"

bash "$repository_root/tests/check-target/run.sh"

greenfield_root="$repository_root/examples/greenfield-notes"
if [[ ! -f "$greenfield_root/INTERVIEW.md" ]]; then
  echo "Missing example file: examples/greenfield-notes/INTERVIEW.md" >&2
  exit 1
fi
"$repository_root/scripts/check-target.sh" --no-skills --agents claude,codex "$greenfield_root"
python3 - "$greenfield_root" <<'PY'
import re
import sys
from pathlib import Path

errors = []
for name in ("project-map.md", "capability-map.md"):
    path = Path(sys.argv[1]) / "docs" / "agent" / name
    status_column = None
    for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not line.startswith("|"):
            status_column = None
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if "Status" in cells:
            status_column = cells.index("Status")
        elif status_column is not None and not set(cells[0]) <= set("-: "):
            value = re.sub(r"[`\s]", "", cells[status_column]).lower() if status_column < len(cells) else ""
            if value not in ("planned", "unknown"):
                errors.append(f"examples/greenfield-notes/docs/agent/{name}:{number}: status must be planned or unknown before scaffolding, got {cells[status_column]!r}")
    for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not line.startswith(("|", "#", "Status:", "Last verified", "Verified on")) and re.search(r"\bverified\b", line, re.IGNORECASE) and "planned" not in line:
            errors.append(f"examples/greenfield-notes/docs/agent/{name}:{number}: prose claims something is verified")
if errors:
    print("\n".join(errors), file=sys.stderr)
    raise SystemExit(1)
PY

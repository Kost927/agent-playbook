#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repository_root"

required_files=(
  README.md
  bootstrap.md
  greenfield.md
  onboarding.md
  audit.md
  workflow.md
  integrations.md
  docs/flow.html
  skills/initialize-agent-workflow/SKILL.md
  skills/execute-task-workflow/SKILL.md
  skills/review-task/SKILL.md
  roles/implementer.md
  roles/reviewer.md
  roles/acceptance-tester.md
  templates/acceptance.md
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
  templates/pr-body.md
  templates/ux-flow.md
  templates/architecture.md
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
    if ".git" in document.parts or ".superpowers" in document.parts:
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
    "workflow.md": ["## Questions and checkpoints", "look first", "Lead with your recommendation", "one at a time", "list assumptions in the final report", "wait for approval", "new checkpoint", "Decisions table", "before writing tests or implementation code", "stop editing", "run the Standard/Full checkpoint"],
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
    "README.md": ["for Claude Code, Codex, and Cursor"],
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

process_rules = {
    "templates/local-workflow.md": ["git clone --depth 1 --branch <revision>", "full 40 characters", "ask the human before recording", "split into phases", "final fresh-context review of the whole branch", "squash commit message", "Acceptance plan hash", "git hash-object --stdin"],
    "workflow.md": ["read-only clone at the pinned revision", "split into phases", "final fresh-context review of the whole branch", "squash commit message", "Acceptance plan hash", "git hash-object --stdin"],
    "skills/review-task/SKILL.md": ["ask the human before recording", "whole branch", "Acceptance plan hash"],
    "bootstrap.md": ["full 40-character commit SHA"],
    "roles/reviewer.md": ["ask the human before recording", "Acceptance plan hash"],
    "skills/execute-task-workflow/SKILL.md": ["Acceptance plan commit", "acceptance tester", "before review", "squash commit message"],
    "audit.md": ["Acceptance plan hash"],
    "roles/acceptance-tester.md": ["Acceptance plan hash"],
    "templates/task.md": ["Acceptance plan hash:"],
    "templates/pr-body.md": ["Acceptance plan hash"],
}
for rule_file, phrases in process_rules.items():
    rule_text = (root / rule_file).read_text(encoding="utf-8")
    for phrase in phrases:
        if phrase not in rule_text:
            errors.append(f"{rule_file}: missing process rule: {phrase}")

integrity_rules = {
    "workflow.md": ["Tests commit", "check-tests-diff.sh", "--repo <target>", "weakened in place", "minimal stubs", "new tests-only commit", "New tests added after the tests commit are allowed", "git hook rejects the tests commit", "never bypass hooks without that decision"],
    "templates/local-workflow.md": ["Tests commit", "check-tests-diff.sh", "--repo <target>", "minimal stubs", "new tests-only commit", "heuristic", "git hook rejects the tests commit", "never skip or weaken tests, or bypass hooks, to get past it"],
    "audit.md": ["**Git hooks against tests-first:**", "Local additions"],
    "roles/reviewer.md": ["--repo <target>", "weakened in place"],
    "skills/review-task/SKILL.md": ["--repo <target>"],
    "templates/task.md": ["Tests commit:"],
    "templates/review-report.md": ["## Test integrity"],
    "roles/reviewer.md": ["check-tests-diff.sh"],
    "skills/review-task/SKILL.md": ["check-tests-diff.sh"],
    "roles/implementer.md": ["Tests commit"],
}
for rule_file, phrases in integrity_rules.items():
    rule_text = (root / rule_file).read_text(encoding="utf-8")
    for phrase in phrases:
        if phrase not in rule_text:
            errors.append(f"{rule_file}: missing integrity rule: {phrase}")

spec_rules = {
    "templates/specification.md": ["## Goals", "## User stories", "| ID | Story | Type | Given | When | Then |"],
    "workflow.md": ["No open questions, because", "n/a: <reason>", "Contracts and invariants", "two teams"],
    "templates/local-workflow.md": ["No open questions, because", "every user story"],
}
for rule_file, phrases in spec_rules.items():
    rule_text = (root / rule_file).read_text(encoding="utf-8")
    for phrase in phrases:
        if phrase not in rule_text:
            errors.append(f"{rule_file}: missing spec rule: {phrase}")

size_rules = {
    "workflow.md": ["| Signal | Direct | Fast | Standard | Full |", "Risk always overrides size", "uncertain risk", "about 500 changed lines", "Task: <id>", "Any migration", "both are uncertain", "When review starts", "implementation session"],
    "templates/task.md": ["## Size check"],
    "templates/local-workflow.md": ["Risk always overrides size", "about 500 changed lines", "Task: <id>", "Any migration", "When review starts"],
}
for rule_file, phrases in size_rules.items():
    rule_text = (root / rule_file).read_text(encoding="utf-8")
    for phrase in phrases:
        if phrase not in rule_text:
            errors.append(f"{rule_file}: missing size rule: {phrase}")

ship_rules = {
    "workflow.md": ["templates/pr-body.md", "keeps a changelog", "Security: static analysis", "clean checkout", "DAST", "staging"],
    "templates/project-map.md": ["Security: static analysis (SAST)", "Security: dependency audit", "Security: dynamic scan (DAST)", "Staging or preview"],
    "templates/local-workflow.md": ["clean checkout", "security", "pr-body", "means that path in the Playbook source at the Playbook revision", "playbook unavailable", "propose adding them"],
    "templates/pr-body.md": ["n/a — Direct/Fast"],
    "bootstrap.md": ["dependency audit"],
    "roles/reviewer.md": ["clean checkout"],
}
for rule_file, phrases in ship_rules.items():
    rule_text = (root / rule_file).read_text(encoding="utf-8")
    for phrase in phrases:
        if phrase not in rule_text:
            errors.append(f"{rule_file}: missing ship rule: {phrase}")
pr_template = root / "templates/pr-body.md"
if pr_template.exists():
    for heading in ("## Acceptance criteria evidence", "## Test integrity", "## Security checks", "## Release note"):
        if heading not in pr_template.read_text(encoding="utf-8"):
            errors.append(f"templates/pr-body.md: missing {heading}")

artifact_rules = {
    "workflow.md": ["templates/ux-flow.md", "templates/architecture.md", "Mutation testing", "existing components", "before this checkpoint", "Critical domain logic means", "never install"],
    "templates/local-workflow.md": ["ux-flow", "architecture", "Mutation testing", "never install"],
    "templates/pr-body.md": ["Mutation testing"],
    "templates/project-map.md": ["Quality: mutation testing"],
    "templates/capability-map.md": ["Design system"],
    "bootstrap.md": ["design system", "mutation"],
}
for rule_file, phrases in artifact_rules.items():
    rule_text = (root / rule_file).read_text(encoding="utf-8")
    for phrase in phrases:
        if phrase not in rule_text:
            errors.append(f"{rule_file}: missing artifact rule: {phrase}")

onboarding_rules = {
    "bootstrap.md": ["(onboarding.md)", "Independent review", "asked, not answered"],
    "onboarding.md": ["one decision at a time", "(Recommended)", "asked, not answered", "Silence is never acceptance", "Considered, not risk zones", "never re-asks", "explicit yes", "owner installs"],
    "workflow.md": ["starts at that zone's minimum route", "Ask one decision at a time", "structured question tool"],
    "templates/local-workflow.md": ["starts at that zone's minimum route", "| Independent review |"],
    "templates/capability-map.md": ["## Risk zones", "| Zone | Paths | Why | Minimum route | Source |", "Considered, not risk zones"],
    "templates/integration-map.md": ["## Tools (MCP servers and plugins)", "| Tool and version | Need | Scope | Config path | Status | Approved on |"],
    "integrations.md": ["## Recommending MCP servers and plugins", "environment-variable references", "read-only", "never production credentials"],
    "onboarding.md#roster": ["Onboarding may add the `Independent review` row and fill roster rows that are missing, `unknown — asked, not answered`, or `session default` when the owner asks, only from the owner's answers; it never changes another recorded model."],
    "bootstrap.md#roster": ["Onboarding may add the `Independent review` row and fill roster rows that are missing, `unknown — asked, not answered`, or `session default` when the owner asks, only from the owner's answers; it never changes another recorded model."],
    "templates/local-workflow.md#roster": ["Onboarding may add the `Independent review` row and fill roster rows that are missing, `unknown — asked, not answered`, or `session default` when the owner asks, only from the owner's answers; it never changes another recorded model."],
    "templates/integration-map.md#status": ["exactly one of these values, with no suffix"],
    "templates/capability-map.md#unanswered": ["| unknown — asked, not answered (<YYYY-MM-DD>) | — | — | — | — |"],
    "examples/task-tracker/docs/agent/integrations.md": ["| declined |"],
    "examples/task-tracker/docs/agent/workflow.md": ["| deep | `session default` (owner, 2026-11-21) |"],
    "examples/greenfield-notes/docs/agent/workflow.md": ["| deep | `session default` (owner, 2026-11-21) |"],
    "docs/flow.html": ["onboarding.md", '["Onboard", ', '["Онбоардинг", ', '["Онбординг", '],
}
cursor_rules = {
    "bootstrap.md": [".cursor/rules", ".cursorrules", "Cursor reads"],
    "onboarding.md": [".cursor/mcp.json"],
    "integrations.md": [".cursor/mcp.json", "${env:NAME}"],
    "README.md": ["Cursor", "Name only the agents you use"],
    "docs/flow.html": ["Cursor"],
    "skills/initialize-agent-workflow/SKILL.md": ["Cursor"],
}
if "(keep only" in (root / "README.md").read_text(encoding="utf-8"):
    errors.append("README.md: agent-list note must sit outside the quick-start prompt")
for rule_file, phrases in cursor_rules.items():
    rule_text = (root / rule_file).read_text(encoding="utf-8")
    for phrase in phrases:
        if phrase not in rule_text:
            errors.append(f"{rule_file}: missing Cursor rule: {phrase}")

audit_rules = {
    "bootstrap.md": ["Template files carry filling instructions", "(audit.md)", "Before step 1.1", "approved repository findings must be gone", "<!-- Generated by the Agent Playbook."],
    "onboarding.md": ["(audit.md)", "Setup audit"],
    "greenfield.md": ["(audit.md)"],
    "audit.md": ["agent-docs-ignored", "agent-tasks-ignored", "scripts/audit-ai-setup.sh", "--global", "user-level:", "never fixes user-level", "judgment:", "Setup audit"],
    "templates/integration-map.md": ["## AI setup audit", "User-level audit:", "| Kind | Location | Decision | Source |"],
    "README.md": ["You may read my user-level AI setup (names and descriptions only) for the audit."],
    "integrations.md": ["Detection markers", "(audit.md)"],
    "examples/task-tracker/ONBOARDING.md": ["Setup audit"],
    "examples/task-tracker/docs/agent/integrations.md": ["User-level audit: declined (owner, 2026-11-21)"],
    "docs/flow.html": ["audit.md", '["Audit AI setup", ', '["Аудит AI", ', '["Аудит AI-настроек", ', 'data-lang="ru"'],
}
for rule_file, phrases in audit_rules.items():
    rule_path = root / rule_file
    rule_text = rule_path.read_text(encoding="utf-8") if rule_path.exists() else ""
    for phrase in phrases:
        if phrase not in rule_text:
            errors.append(f"{rule_file}: missing audit rule: {phrase}")
markers_match = re.search(r"MARKERS = \{([^}]*)\}", (root / "scripts/audit-ai-setup.sh").read_text(encoding="utf-8"))
integrations_text = (root / "integrations.md").read_text(encoding="utf-8")
for marker in re.findall(r'"([^"]+)":', markers_match.group(1) if markers_match else ""):
    if f"`{marker}`" not in integrations_text:
        errors.append(f"integrations.md: detection marker {marker} from scripts/audit-ai-setup.sh is not listed")

notest_rules = {
    "templates/agents-entry.md": ["Workflow precedence:"],
    "bootstrap.md": ["`none configured`"],
    "workflow.md": ["### Repositories without a test runner", "Acceptance plan commit", "propose adding a test runner"],
    "templates/local-workflow.md": ["Acceptance plan commit", "no test runner", "roles/acceptance-tester.md"],
    "templates/task.md": ["Acceptance plan commit"],
    "templates/pr-body.md": ["acceptance plan"],
    "workflow.md#acceptance": ["### 8a. Check acceptance in the running software", "never uses production"],
    "roles/acceptance-tester.md": ["Never use production", "real payments", "never install a tool", "do not read the implementation"],
    "roles/reviewer.md": ["acceptance plan was committed before implementation"],
    "onboarding.md": ["acceptance checks"],
    "templates/project-map.md": ["Agents may use it for acceptance checks"],
    "docs/flow.html": ["Acceptance check in the running app", "Перевірка приймання в запущеному застосунку", "Проверка приемки в запущенном приложении"],
}
for rule_file, phrases in notest_rules.items():
    rule_text = (root / rule_file.split("#", 1)[0]).read_text(encoding="utf-8")
    for phrase in phrases:
        if phrase not in rule_text:
            errors.append(f"{rule_file}: missing no-test-runner rule: {phrase}")

review_fix_rules = {
    "onboarding.md": ["Whenever a staging or preview environment exists", "never a password"],
    "workflow.md#plan": ["Whenever step 8a will apply", "`fail` is always blocking", "explicit owner acceptance", "report `no automated tests`", "create the acceptance plan commit at that point"],
    "templates/local-workflow.md#plan": ["whenever the acceptance tester will run"],
    "roles/acceptance-tester.md#safety": ["which backend", "real people", "the project's own dependencies", "integrations.md", "personal data"],
    "roles/reviewer.md#fail": ["`fail` is blocking", "When the repository has a test runner, verify", "latest acceptance plan commit"],
    "roles/implementer.md": ["Plan section"],
    "skills/review-task/SKILL.md": ["acceptance.md"],
    "templates/agents-entry.md#precedence": ["unless the human asks otherwise in the session"],
    "templates/pr-body.md#na": ["n/a — no test runner"],
    "templates/review-report.md": ["n/a — no test runner"],
    "templates/task.md#list": ["in order"],
    "audit.md#gitignore": ["`docs/*` then `!docs/agent/`"],
    "templates/capability-map.md#visible": ["\nOnly include workstreams supported by evidence", "\nIf the owner names none, keep one row"],
}
for rule_file, phrases in review_fix_rules.items():
    rule_text = (root / rule_file.split("#", 1)[0]).read_text(encoding="utf-8")
    for phrase in phrases:
        if phrase not in rule_text:
            errors.append(f"{rule_file.split('#', 1)[0]}: missing review-fix rule: {phrase}")

safety_rules = {
    "workflow.md#deploy": ["## Safety on every route", "general \"do it\"", "force-push", "auto-merge", "release/*"],
    "templates/local-workflow.md#deploy": ["## Safety on every route", "branch that deploys", "never ask for passwords"],
    "templates/project-map.md#deploy": ["Branches that deploy on push or merge", "Other deploy triggers", "Test account credentials"],
    "bootstrap.md#deploy": ["branches that deploy"],
    "skills/execute-task-workflow/SKILL.md#deploy": ["Safety on every route", "general \"do it\""],
    "roles/acceptance-tester.md#secrets": ["Never ask for passwords"],
    "workflow.md#secrets": ["Never ask for passwords"],
}
for rule_file, phrases in safety_rules.items():
    rule_text = (root / rule_file.split("#", 1)[0]).read_text(encoding="utf-8")
    for phrase in phrases:
        if phrase not in rule_text:
            errors.append(f"{rule_file.split('#', 1)[0]}: missing safety rule: {phrase}")

for rule_file, phrases in onboarding_rules.items():
    rule_path = root / rule_file.split("#", 1)[0]
    rule_text = rule_path.read_text(encoding="utf-8") if rule_path.exists() else ""
    for phrase in phrases:
        if phrase not in rule_text:
            errors.append(f"{rule_file.split('#', 1)[0]}: missing onboarding rule: {phrase}")

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

if [[ ! -f "$example_root/ONBOARDING.md" ]]; then
  echo "Missing example file: examples/task-tracker/ONBOARDING.md" >&2
  exit 1
fi
"$repository_root/scripts/check-target.sh" --no-skills --agents claude,codex "$example_root"

bash "$repository_root/tests/check-target/run.sh"
bash "$repository_root/tests/audit-ai-setup/run.sh"
for example in task-tracker greenfield-notes; do
  if ! audit_output="$("$repository_root/scripts/audit-ai-setup.sh" "$repository_root/examples/$example")"; then
    echo "$audit_output" >&2
    echo "examples/$example: AI setup audit reports warnings" >&2
    exit 1
  fi
done

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

bash "$repository_root/tests/check-tests-diff/run.sh"

example_spec="$repository_root/examples/task-tracker/docs/agent/tasks/002-due-dates/specification.md"
if [[ ! -f "$example_spec" ]]; then
  echo "Missing example specification: examples/task-tracker/docs/agent/tasks/002-due-dates/specification.md" >&2
  exit 1
fi
if grep -n '`<' "$example_spec"; then
  echo "Unfilled placeholder in the example specification" >&2
  exit 1
fi
for required in '| happy |' '| error |' 'n/a:'; do
  if ! grep -qF -- "$required" "$example_spec"; then
    echo "Example specification is missing: $required" >&2
    exit 1
  fi
done

if [[ ! -f "$repository_root/examples/task-tracker/docs/agent/tasks/002-due-dates/ux-flow.md" ]]; then
  echo "Missing example UX flow: examples/task-tracker/docs/agent/tasks/002-due-dates/ux-flow.md" >&2
  exit 1
fi

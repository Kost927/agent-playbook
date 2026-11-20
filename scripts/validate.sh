#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repository_root"

required_files=(
  README.md
  bootstrap.md
  workflow.md
  integrations.md
  docs/flow.html
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

if errors:
    print("\n".join(errors), file=sys.stderr)
    raise SystemExit(1)

print("Validated required files and local Markdown link targets.")
PY

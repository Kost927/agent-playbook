# Agent Instructions for the Playbook Repository

This repository is the Agent Playbook itself, not a target repository.

- Validate every change with `bash scripts/validate.sh`.
- `examples/` holds target-repository fixtures. Their `AGENTS.md`, `CLAUDE.md`, and `docs/agent/` files describe the example project and apply only to work on that example's code. They do not govern changes to the playbook.
- When you change a template, regenerate the affected example files so `scripts/check-target.sh examples/task-tracker` still passes.
- Design documents and plans live in `docs/superpowers/`.

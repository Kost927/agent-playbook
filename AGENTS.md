# Agent Instructions for the Playbook Repository

This repository is the Agent Playbook itself, not a target repository.

- Validate every change with `bash scripts/validate.sh`.
- `examples/` holds target-repository fixtures. Their `AGENTS.md`, `CLAUDE.md`, and `docs/agent/` files describe the example project and apply only to work on that example's code. They do not govern changes to the playbook.
- When you change a template, regenerate the affected example files so `scripts/check-target.sh` still passes on both examples.
- The playbook revision recorded in an example is the commit it was first generated from. A commit cannot record its own hash, so after regeneration that field can lag behind the content; treat the template as the source of truth.
- Design documents and plans live in `docs/superpowers/`.

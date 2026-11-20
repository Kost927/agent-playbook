# Team Notes

A small internal web app where our six-person support team keeps shared how-to notes. It should replace the long Google Doc we use today, which nobody can search properly.

## Agent workflow files

This directory is the playbook's greenfield example: the repository as it looks right after greenfield initialization, before any code exists. The README above is the human's original text.

- [`INTERVIEW.md`](INTERVIEW.md) — the (synthetic) interview that produced these files.
- [`AGENTS.md`](AGENTS.md) and [`CLAUDE.md`](CLAUDE.md) — entry points.
- [`docs/agent/product-brief.md`](docs/agent/product-brief.md) — interview results.
- [`docs/adr/0001-stack.md`](docs/adr/0001-stack.md) — stack decision, `proposed`.
- [`docs/agent/project-map.md`](docs/agent/project-map.md) and [`docs/agent/capability-map.md`](docs/agent/capability-map.md) — every entry `planned` or `unknown`.
- [`docs/agent/tasks/001-scaffold.md`](docs/agent/tasks/001-scaffold.md) — the first task, blocked until the ADR is accepted.

Workflow skill copies are omitted, as in `examples/task-tracker/`.

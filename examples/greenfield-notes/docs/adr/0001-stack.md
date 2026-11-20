# ADR-`0001`: `Stack for Team Notes`

Status: `proposed`  
Date: `2026-11-21`  
Deciders: `the maintainer (deferred to the agent's recommendation; awaiting confirmation)`

## Context

Team Notes is an internal notes app for a six-person support team (`docs/agent/product-brief.md`). It has one maintainer who knows TypeScript well, must run on an existing Linux VM with Docker, has no budget for paid services, must require Google Workspace sign-in, and stores no customer data.

## Options considered

| Option | Trade-offs | Fit with constraints |
| --- | --- | --- |
| A. TypeScript: Node.js server with server-rendered pages, SQLite with full-text search, one Docker container | Few moving parts; SQLite search is enough at this scale; sign-in integration written by hand | Matches the maintainer's strongest language; runs on the VM; no paid services |
| B. Python: Django with SQLite | Built-in admin, auth, and migrations; more framework to learn | Python is the maintainer's weaker language |
| C. Self-hosted open-source wiki | No code; limited control over search and layout; another product to upgrade | Fits hosting and budget; the team adapts to the tool |

## Decision

Option A, recommended by the agent. The human answered "you decide", so the status stays `proposed` until the human confirms it.

## Consequences

- The scaffolding task (`docs/agent/tasks/001-scaffold.md`) is blocked until this ADR is accepted.
- Planned commands in the project map (`npm ci`, `npm test`, `npm run lint`, `npm run typecheck`, `npm run build`) follow from this option and become verified only after scaffolding.
- Revisit if the team grows well beyond one support team or if customer data enters scope.

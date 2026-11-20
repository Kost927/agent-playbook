# ADR-`0001`: `Stack for Team Notes`

Status: `proposed`  
Date: `2026-11-21`  
Deciders: `the maintainer (deferred to the agent's recommendation; awaiting confirmation)`

## Context

Team Notes is an internal notes app for a six-person support team (`docs/agent/product-brief.md`). It has one maintainer who knows TypeScript well, must run on an existing Linux VM with Docker, has no budget for paid services, must require Google Workspace sign-in, and stores no customer data.

## Options considered

| Option | Trade-offs | Fit with constraints |
| --- | --- | --- |
| A. TypeScript: Node.js server with server-rendered pages, SQLite with FTS5 full-text search, one Docker container | Few moving parts; FTS5 search is enough at this scale; full control over search and layout; Google sign-in integration written by hand | Matches the maintainer's strongest language; runs on the VM; no paid services |
| B. Python: Django with SQLite | Built-in admin, auth, and migrations; more framework to learn | Python is the maintainer's weaker language |
| C. Self-hosted open-source wiki | Fastest to the milestone: search and Google/OAuth sign-in usually built in, no code; limited control over search ranking and layout; another product to upgrade | Fits hosting, budget, and sign-in; the team adapts to the tool |

## Decision

Option A, recommended by the agent because the success criterion depends on search quality, which A controls fully, and it avoids upgrading a third-party product with one maintainer. C is the alternative if speed to a first version matters more. The human answered "you decide", so the status stays `proposed` until the human confirms it.

## Consequences

- The scaffolding task (`docs/agent/tasks/001-scaffold.md`) is blocked until this ADR is accepted.
- Planned commands in the project map (`npm ci`, `npm test`, `npm run lint`, `npm run typecheck`, `npm run build`) follow from this option and become verified only after scaffolding.
- Revisit if the team grows well beyond one support team or if customer data enters scope.

# Product Brief: `Team Notes`

Status: `accepted`  
Interviewed on: `2026-11-21`  
Source: `README.md and the greenfield interview (INTERVIEW.md)`

This brief records what the human said during the greenfield interview. Agent proposals that the human accepted are marked as such.

## Product and users

- What is being built: an internal web app for shared how-to notes, replacing a long Google Doc that is hard to search (README).
- Primary users: the six-person support team, including new hires (README; new hires added in answer 1).
- Why now: the current document cannot be searched effectively (README).

## Success

- The team stops editing the Google Doc and finds an answer by search in under a minute (agent proposal, accepted in answer 1).
- New hires find answers without asking a colleague (answer 1).

## Non-goals

- Public sharing, real-time co-editing, a mobile app (agent proposal, accepted in answer 2).
- Comments on notes (answer 2).

## Constraints

| Constraint | Value | Source |
| --- | --- | --- |
| Team skills | One maintainer; strong TypeScript, some Python | Answer 3 |
| Hosting and runtime | Existing small Linux VM with Docker | Answer 4 |
| Budget and cost | No budget for paid services | Answer 6 |
| Compliance and data | No customer data; internal procedures only; company login required | Answer 5 |
| Organization standards | Google Workspace sign-in; nothing else mandated | Answers 4 and 6 |

## First milestone

Create, edit, and delete notes; full-text search; Google sign-in; deployed on the VM. The existing Google Doc is imported manually (agent proposal, accepted in answer 7).

## Decisions

- Stack: `docs/adr/0001-stack.md` — `proposed` (the human deferred the choice)

## Open questions

- Confirm the stack in ADR-0001 (the human).
- Who besides the maintainer can deploy to the VM (the human).

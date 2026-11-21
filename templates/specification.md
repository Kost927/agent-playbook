# Specification: `<TASK_TITLE>`

Status: `<draft | accepted | superseded>`  
Owner: `<name or role>`  
Original request: `<verbatim request or durable link>`

## Problem and user

Describe the user, current behavior, problem, and desired outcome.

## Goals

- `<outcome for users or the business>` — measured by `<observable success measure, not a restated criterion>`

## User stories

- `US-1`: As a `<role>`, I want `<capability>`, so that `<outcome>`.

## Scope

### In scope

- `<observable outcome>`

### Out of scope

- `<explicit boundary>`

## Affected units and workstreams

| Unit/boundary | Active capability workstreams | Reason |
| --- | --- | --- |
| `<repository term and path>` | `<detected concerns>` | `<observable impact or dependency>` |

## Acceptance criteria

| ID | Story | Type | Given | When | Then |
| --- | --- | --- | --- | --- | --- |
| AC-1 | `<US-n>` | `<happy, error, edge, authorization, invariant, or compatibility>` | `<starting state>` | `<action/event>` | `<observable result>` |

Describe behavior in the user's or consumer's terms; naming the surface (API, CLI, screen) is fine. Put paths, status codes, schemas, and queries in Contracts and invariants and reference them. Every user story needs at least one criterion; `happy` and `error` are required, and `edge`, `authorization`, `invariant`, and `compatibility` are required when relevant. Also consider recovery, accessibility, and operational behavior.

- Not relevant here: `<type> — n/a: <reason>`

## Contracts and invariants

- `<interface, protocol, event, data, state, artifact, or deployment contract>`
- `<behavior that must remain unchanged>`

## Assumptions

- `<assumption the agent made, and how it can be confirmed>`

## Risks and rollout

- Risk: `<risk>` — Mitigation: `<mitigation>`
- Rollback: `<verified mechanism or undecided>`

## Decisions

| Decision | Options considered | Choice and reason |
| --- | --- | --- |
| `<question>` | `<options>` | `<decision>` |

## Open questions

- `<question that still blocks or limits verification>`

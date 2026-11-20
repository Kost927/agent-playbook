# Capability Map

Last verified against commit: `<COMMIT_SHA>`  
Verified on: `<YYYY-MM-DD>`  
Update the date and commit only when this file's facts change.

Status: `verified` = found in the repository or executed; `planned` = decided but not yet present (greenfield). `unknown` = not yet decided or discovered. Allowed values: `planned | verified | unknown`.

This map is derived from repository evidence. It is not a fixed frontend/backend classification.

## Units and boundaries

| Unit or subsystem | Paths | Built/tested/deployed/published as | Dependencies and consumers | Status |
| --- | --- | --- | --- | --- |
| `<repository term>` | `<paths>` | `<verified lifecycle>` | `<verified relationships>` | `<planned/verified/unknown>` |

## Detected capability workstreams

| Workstream | Scope and entry points | Contracts/invariants | Validation and good examples | Status |
| --- | --- | --- | --- | --- |
| `<interaction, contract, data, async, artifact, infrastructure, security, or repository-specific term>` | `<paths>` | `<observable promises>` | `<commands/tests/example paths>` | `<planned/verified/unknown>` |

Only include workstreams supported by evidence, or `planned` workstreams traced to the product brief or stack ADR. One unit may have multiple rows.

## Cross-cutting concerns

Record concerns spanning multiple units, such as identity, authorization, observability, configuration, generation, localization, accessibility, privacy, performance, or release ordering.

## Scope rules

- Root commands and policy: `<evidence>`
- Unit-scoped commands and policy: `<evidence>`
- Affected/dependent-unit selection: `<tool/configuration or manual rule>`
- Nested instruction boundaries: `<paths or none>`

## Unknowns and external facts

- `<consumer, production scale, ownership, operational, or compliance fact not established by the repository>`

## Maintenance triggers

Update this map when units, interfaces, dependency direction, commands, ownership, compatibility promises, deployment topology, or cross-cutting policy changes.

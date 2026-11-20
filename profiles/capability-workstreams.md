# Capability Workstreams

This is not a catalog of technology profiles. It is a technology-neutral set of concerns that an agent composes from repository evidence. A single task may activate several workstreams, and a single component may participate in more than one.

Do not label a repository “frontend” or “backend” and stop discovery. Map what the repository exposes, consumes, stores, publishes, executes, and deploys.

## Universal discovery

For every independently built, tested, deployed, published, or owned unit, record:

- paths, entry points, owners, dependencies, and dependents;
- runtime/build environment and generated artifacts;
- inbound and outbound interfaces;
- compatibility promises and consumers;
- state, persistence, concurrency, and failure boundaries;
- commands and CI jobs that verify it;
- deployment/publication and rollback mechanisms;
- logs, metrics, traces, alerts, and operational constraints;
- concrete good examples already present in the repository.

Activate only the workstreams supported by evidence or required by the task.

## Interaction surfaces

Apply to any human-facing or machine-operated interface: graphical, command-line, textual, device, accessibility, or administrative.

Discover navigation or invocation paths, input validation, state ownership, feedback, error and recovery behavior, accessibility/usability constraints, localization, supported environments, and representative tests. Review observable behavior rather than framework internals.

## Service and contract boundaries

Apply to network APIs, local protocols, events, messages, files, plugins, extension points, or any producer/consumer boundary.

Discover schemas, versioning, authentication/authorization, timeouts, retries, idempotency, ordering, error semantics, rate/resource limits, generated code, consumers, and compatibility rules. Validate contract changes from both producer and consumer perspectives.

## Data and state

Apply when a task reads, writes, migrates, caches, indexes, or synchronizes durable or shared state.

Discover schemas, ownership, invariants, volume assumptions, transactional boundaries, concurrency, retention, privacy, migration/rollback strategy, backups, cache invalidation, and reconciliation. Repository code may not reveal production scale; record operational facts as unknown until verified.

## Asynchronous and scheduled execution

Apply to queues, streams, workers, schedulers, workflows, hooks, and background jobs.

Discover delivery guarantees, deduplication, ordering, retries, backoff, poison-item handling, cancellation, replay, observability, and partial-failure recovery. Test temporal and duplicate-delivery behavior where relevant.

## Reusable or published artifacts

Apply to libraries, SDKs, packages, modules, schemas, images, plugins, templates, and generated artifacts consumed outside their defining unit.

Discover public surface, supported environments, semantic/versioning policy, deprecation, binary/source compatibility, publication, provenance, consumer tests, and release notes. Treat an internal package with multiple consumers as a contract boundary even if it is not public.

## Infrastructure and delivery

Apply to build systems, CI/CD, infrastructure definitions, deployment manifests, configuration, feature flags, and operational tooling.

Discover environment differences, secrets boundaries, permissions, plan/preview mechanisms, rollout order, health checks, rollback, drift, blast radius, and post-change signals. Prefer dry-run or validation mechanisms when available; never infer production authorization from repository access.

## Security, privacy, and compliance

Activate whenever the task affects trust boundaries, identity, permissions, untrusted input, secrets, sensitive data, auditing, retention, or regulated behavior.

Discover threat boundaries, authorization enforcement points, data classification, validation/encoding, encryption, credential handling, audit requirements, dependency/provenance controls, and incident signals. Security is cross-cutting and may escalate any task to the Full route.

## Monorepo and multi-unit composition

This is a scoping rule, not a technology profile.

- Map the unit graph and distinguish root commands from scoped commands.
- Identify shared configuration, generated outputs, ownership, and release coupling.
- Determine the complete affected-unit set, including downstream consumers.
- Use root instructions for shared policy and nested instructions only for genuinely different local facts.
- Validate at the narrowest sufficient scope, then run required affected/dependent checks.
- Avoid copying the central workflow into every package; reference it and keep local deltas close to their boundary.

## Task activation record

For Standard and Full tasks, record:

| Workstream | Affected scope | Relevant criteria/risks | Required evidence |
| --- | --- | --- | --- |
| `<detected concern>` | `<paths/units>` | `<AC IDs and risks>` | `<tests, commands, review>` |

If a workstream is plausibly affected but evidence is unavailable, mark it as an unresolved risk rather than silently omitting it.

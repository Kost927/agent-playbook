# Specification: `Due dates and overdue tasks`

Status: `accepted`  
Owner: `example maintainer`  
Original request: `"Add due dates to tasks and a way to see what's overdue."`

This is a worked example of the playbook's specification template for a Standard-route task. The feature is proposed, not implemented.

## Problem and user

Team members track tasks with the HTTP API and the CLI, but tasks have no deadline, so nobody can tell what is late. They want to record a due date and see overdue work at a glance.

## Goals

- Team members can tell which tasks are late without asking each other — measured by: two weeks after release, the team no longer keeps deadlines outside the tracker (confirmed by the owner).
- Late work gets attention first — measured by: overdue tasks are reviewed from the tracker's overdue list at the team's daily check-in.

## User stories

- `US-1`: As a team member, I want to set a due date when I create a task, so that its deadline is recorded.
- `US-2`: As a team member, I want to list overdue tasks, so that I know what needs attention first.
- `US-3`: As an existing API or CLI consumer, I want my current requests, commands, and data to keep working, so that the change does not break my scripts.

## Scope

### In scope

- An optional due date on new tasks, through the API and the CLI.
- Listing overdue open tasks through the API and the CLI.
- Migrating existing databases.

### Out of scope

- Changing the due date of an existing task.
- Reminders, notifications, or times of day.

## Affected units and workstreams

| Unit/boundary | Active capability workstreams | Reason |
| --- | --- | --- |
| `tracker` package: `src/tracker/api.py` | Service and contract boundaries | New request field and list filter |
| `tracker` package: `src/tracker/cli.py` | Interaction surface (CLI) | New option and output |
| `tracker` package: `src/tracker/db.py`, `migrations/` | Data and state | New column and migration on existing databases |

## Acceptance criteria

| ID | Story | Type | Given | When | Then |
| --- | --- | --- | --- | --- | --- |
| AC-1 | US-1 | happy | An empty task list | A team member creates "Ship release" due on 2026-12-01 through the API | The API task list shows "Ship release" with due date 2026-12-01 |
| AC-2 | US-1 | happy | An empty task list | A team member adds "Ship release" due on 2026-12-01 with the CLI | The CLI list shows "Ship release" with due date 2026-12-01 |
| AC-3 | US-1 | error | Any task list | A team member creates a task through the API or the CLI with a due date that is not a real date in the agreed format, such as 2026-02-30 or 12/01/2026 | The task is rejected with a message that names the due date as the problem, and no task is stored |
| AC-4 | US-1 | error | Any task list | A team member creates a task through the API with an empty or non-text due value | The task is rejected with the same message, and no task is stored |
| AC-5 | US-1 | edge | Today is 2026-11-21 (UTC) | A team member creates an open task due on 2026-11-20 | The task is stored and immediately appears in the overdue list |
| AC-6 | US-2 | happy | Today is 2026-11-21 (UTC); open tasks due 2026-11-20, 2026-11-21, and 2026-11-22; a completed task due 2026-11-20 | A team member lists overdue tasks through the API or the CLI | Only the open task due 2026-11-20 is listed |
| AC-7 | US-2 | edge | Today is 2026-11-21 (UTC); an open task due 2026-11-21 | A team member lists overdue tasks | The task is not listed: a task is overdue only after its due date has passed |
| AC-8 | US-2 | edge | No open task has a due date in the past | A team member lists overdue tasks | The API returns an empty list, and the CLI prints nothing and succeeds |
| AC-9 | US-2 | error | Any task list | A team member asks the API for an overdue filter value other than the agreed one | The request is rejected with a message naming the filter |
| AC-10 | US-2 | invariant | An overdue open task due 2026-11-20 | A team member completes it | It leaves the overdue list, and its due date is still 2026-11-20 |
| AC-11 | US-3 | compatibility | Tasks without due dates | A consumer adds and lists tasks with the CLI without the new option | Each CLI line has the same text as in the current version |
| AC-12 | US-3 | compatibility | Tasks without due dates | A consumer creates and lists tasks through the API without a due date | Creation succeeds as today; list items keep the same id, title, and done values and gain an empty due date |
| AC-13 | US-3 | compatibility | A database created by the current version with existing tasks | The new version opens it | All existing tasks are kept, with no due date |

Not relevant here:

- `authorization — n/a: the service has no authentication and binds to localhost (capability map, cross-cutting concerns); exposing it would be a separate Full-route task.`

## Contracts and invariants

- API, create (`POST /tasks`): optional field `"due"`, a `YYYY-MM-DD` string; omitted or `null` means no due date. An impossible or wrongly formatted date, an empty string, or a non-string value returns 400 with `{"error": "due must be a valid date in YYYY-MM-DD format"}` (AC-3, AC-4).
- API, list (`GET /tasks`): every item gains `"due"`, a string or `null` (AC-1, AC-12). `GET /tasks?overdue=true` returns overdue open tasks, possibly `[]` (AC-6 to AC-8). Any other `overdue` value returns 400 with `{"error": "overdue must be true"}` (AC-9).
- CLI: `add <title> [--due YYYY-MM-DD]` prints the error to stderr and exits 1 on an invalid date (AC-3). `list --overdue` lists overdue open tasks and exits 0, printing nothing when there are none (AC-6 to AC-8). A task with a due date prints as `[ ] 1 Ship release (due 2026-12-01)`; tasks without one print exactly the current line format (AC-2, AC-11).
- Data: `migrations/002_add_due.sql` adds a nullable `due` text column holding an ISO date. Existing migrations are not edited (AC-13).
- Overdue means: not done, and due date strictly before today's date in UTC (AC-5 to AC-7; see Decisions).

## Assumptions

- None open: every assumption raised at the checkpoint was confirmed and moved to Decisions.

## Risks and rollout

- Risk: the migration runs on existing user databases — Mitigation: the new column is nullable, the migration only adds it, and AC-13 covers existing data.
- Rollback: the previous version ignores the extra column, so rolling back the code is safe; the column stays unused.

## Decisions

| Decision | Options considered | Choice and reason |
| --- | --- | --- |
| Which "today" defines overdue | Server UTC date; client-supplied date; local server time | Server UTC date: the service has no notion of user time zones, and UTC keeps API and CLI consistent (decided at the checkpoint) |
| Date format | ISO `YYYY-MM-DD`; free text; Unix timestamp | ISO date: sortable, unambiguous, and the same in JSON and CLI |
| Time of day | Date only; date and time | Date only: the request is about days, and times would raise time-zone questions for every task (confirmed at the checkpoint) |
| Past due dates at creation | Reject; allow | Allow: tasks are often recorded after their deadline, and they should appear as overdue (AC-5) |

## Open questions

No open questions, because the time-zone, time-of-day, and past-date questions raised at the checkpoint were decided (see Decisions) and the remaining scope is explicit.

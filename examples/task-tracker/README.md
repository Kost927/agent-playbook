# Task Tracker

A small task tracker: a SQLite store with a JSON HTTP API and a command-line interface. Standard library only.

This is the worked example for the Agent Playbook. It is a realistic target repository, not part of the playbook itself.

## Run

```sh
PYTHONPATH=src python3 -m tracker.cli --db tracker.db add "Write docs"
PYTHONPATH=src python3 -m tracker.cli --db tracker.db list
PYTHONPATH=src python3 -m tracker.api   # serves on http://127.0.0.1:8000
```

## Test

```sh
PYTHONPATH=src python3 -m unittest discover -s tests -t .
```

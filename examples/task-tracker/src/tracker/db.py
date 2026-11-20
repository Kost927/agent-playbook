"""SQLite storage in autocommit mode. Migrations in ../../migrations are applied in filename order.

Migration files must contain plain statements separated by semicolons (no triggers or string literals with semicolons).
"""
import sqlite3
from pathlib import Path
from typing import Dict, List

MIGRATIONS = Path(__file__).resolve().parents[2] / "migrations"


def connect(path: str) -> sqlite3.Connection:
    """Open the store and apply pending migrations in one write transaction."""
    conn = sqlite3.connect(path, check_same_thread=False, timeout=10, isolation_level=None)
    conn.execute("BEGIN IMMEDIATE")
    try:
        conn.execute("CREATE TABLE IF NOT EXISTS schema_migrations (name TEXT PRIMARY KEY)")
        applied = {row[0] for row in conn.execute("SELECT name FROM schema_migrations")}
        for migration in sorted(MIGRATIONS.glob("*.sql")):
            if migration.name in applied:
                continue
            for statement in migration.read_text(encoding="utf-8").split(";"):
                if statement.strip():
                    conn.execute(statement)
            conn.execute("INSERT INTO schema_migrations (name) VALUES (?)", (migration.name,))
        conn.execute("COMMIT")
    except Exception:
        conn.execute("ROLLBACK")
        conn.close()
        raise
    return conn


def add_task(conn: sqlite3.Connection, title: str) -> int:
    return conn.execute("INSERT INTO tasks (title) VALUES (?)", (title,)).lastrowid


def list_tasks(conn: sqlite3.Connection) -> List[Dict]:
    rows = conn.execute("SELECT id, title, done FROM tasks ORDER BY id")
    return [{"id": row[0], "title": row[1], "done": bool(row[2])} for row in rows]


def complete_task(conn: sqlite3.Connection, task_id: int) -> bool:
    return conn.execute("UPDATE tasks SET done = 1 WHERE id = ?", (task_id,)).rowcount == 1

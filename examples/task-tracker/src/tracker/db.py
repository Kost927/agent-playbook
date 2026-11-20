"""SQLite storage. Migrations in ../../migrations are applied in filename order."""
import sqlite3
from pathlib import Path
from typing import Dict, List

MIGRATIONS = Path(__file__).resolve().parents[2] / "migrations"


def connect(path: str) -> sqlite3.Connection:
    conn = sqlite3.connect(path, check_same_thread=False)
    conn.execute("CREATE TABLE IF NOT EXISTS schema_migrations (name TEXT PRIMARY KEY)")
    applied = {row[0] for row in conn.execute("SELECT name FROM schema_migrations")}
    for migration in sorted(MIGRATIONS.glob("*.sql")):
        if migration.name not in applied:
            conn.executescript(migration.read_text(encoding="utf-8"))
            conn.execute("INSERT INTO schema_migrations (name) VALUES (?)", (migration.name,))
    conn.commit()
    return conn


def add_task(conn: sqlite3.Connection, title: str) -> int:
    cursor = conn.execute("INSERT INTO tasks (title) VALUES (?)", (title,))
    conn.commit()
    return cursor.lastrowid


def list_tasks(conn: sqlite3.Connection) -> List[Dict]:
    rows = conn.execute("SELECT id, title, done FROM tasks ORDER BY id")
    return [{"id": row[0], "title": row[1], "done": bool(row[2])} for row in rows]


def complete_task(conn: sqlite3.Connection, task_id: int) -> bool:
    cursor = conn.execute("UPDATE tasks SET done = 1 WHERE id = ?", (task_id,))
    conn.commit()
    return cursor.rowcount == 1

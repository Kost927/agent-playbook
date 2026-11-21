import os
import tempfile
import threading
import unittest

from tracker import db


class StoreTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.conn = db.connect(os.path.join(self.tmp.name, "t.db"))

    def tearDown(self):
        self.conn.close()
        self.tmp.cleanup()

    def test_add_and_list(self):
        task_id = db.add_task(self.conn, "Write docs")
        self.assertEqual(db.list_tasks(self.conn), [{"id": task_id, "title": "Write docs", "done": False}])

    def test_complete(self):
        task_id = db.add_task(self.conn, "Ship")
        self.assertTrue(db.complete_task(self.conn, task_id))
        self.assertTrue(db.list_tasks(self.conn)[0]["done"])

    def test_complete_missing(self):
        self.assertFalse(db.complete_task(self.conn, 999))

    def test_reconnect_keeps_data(self):
        path = os.path.join(self.tmp.name, "t.db")
        db.add_task(self.conn, "Persist")
        self.conn.close()
        self.conn = db.connect(path)
        self.assertEqual(len(db.list_tasks(self.conn)), 1)

    def test_concurrent_connect_applies_migration_once(self):
        path = os.path.join(self.tmp.name, "fresh.db")
        errors = []

        def open_store():
            try:
                db.connect(path).close()
            except Exception as error:
                errors.append(error)

        threads = [threading.Thread(target=open_store) for _ in range(8)]
        for thread in threads:
            thread.start()
        for thread in threads:
            thread.join()
        self.assertEqual(errors, [])
        conn = db.connect(path)
        self.assertEqual(conn.execute("SELECT COUNT(*) FROM schema_migrations").fetchone()[0], 1)
        conn.close()

    def test_migration_with_comment_containing_semicolon(self):
        migrations = tempfile.TemporaryDirectory()
        self.addCleanup(migrations.cleanup)
        with open(os.path.join(migrations.name, "001.sql"), "w") as handle:
            handle.write("-- note; still a comment\nCREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, done INTEGER DEFAULT 0);\n")
        original = db.MIGRATIONS
        db.MIGRATIONS = __import__("pathlib").Path(migrations.name)
        self.addCleanup(setattr, db, "MIGRATIONS", original)
        db.connect(os.path.join(self.tmp.name, "c.db")).close()

    def test_broken_migration_reports_original_error(self):
        migrations = tempfile.TemporaryDirectory()
        self.addCleanup(migrations.cleanup)
        with open(os.path.join(migrations.name, "001.sql"), "w") as handle:
            handle.write("CREATE TABLE broken (;\n")
        original = db.MIGRATIONS
        db.MIGRATIONS = __import__("pathlib").Path(migrations.name)
        self.addCleanup(setattr, db, "MIGRATIONS", original)
        with self.assertRaisesRegex(Exception, "syntax error"):
            db.connect(os.path.join(self.tmp.name, "b.db"))

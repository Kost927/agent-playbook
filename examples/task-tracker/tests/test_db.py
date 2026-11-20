import os
import tempfile
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

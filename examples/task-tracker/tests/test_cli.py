import contextlib
import io
import os
import tempfile
import unittest

from tracker.cli import main


class CliTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.db = os.path.join(self.tmp.name, "t.db")

    def tearDown(self):
        self.tmp.cleanup()

    def run_cli(self, *args):
        out = io.StringIO()
        with contextlib.redirect_stdout(out), contextlib.redirect_stderr(io.StringIO()):
            code = main(["--db", self.db, *args])
        return code, out.getvalue()

    def test_add_list_done(self):
        self.assertEqual(self.run_cli("add", "Write docs"), (0, "1\n"))
        self.assertEqual(self.run_cli("done", "1")[0], 0)
        self.assertEqual(self.run_cli("list"), (0, "[x] 1 Write docs\n"))

    def test_done_missing(self):
        self.assertEqual(self.run_cli("done", "999")[0], 1)

    def test_blank_titles_rejected(self):
        self.assertEqual(self.run_cli("add", "")[0], 1)
        self.assertEqual(self.run_cli("add", "   ")[0], 1)
        self.assertEqual(self.run_cli("list"), (0, ""))

    def test_done_huge_id(self):
        self.assertEqual(self.run_cli("done", "99999999999999999999")[0], 1)

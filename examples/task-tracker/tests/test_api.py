import json
import os
import tempfile
import threading
import unittest
import urllib.error
import urllib.request
from http.server import HTTPServer

from tracker.api import make_handler


class ApiTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.server = HTTPServer(("127.0.0.1", 0), make_handler(os.path.join(self.tmp.name, "t.db")))
        threading.Thread(target=self.server.serve_forever, daemon=True).start()
        self.base = "http://127.0.0.1:%d" % self.server.server_address[1]

    def tearDown(self):
        self.server.shutdown()
        self.server.server_close()
        self.tmp.cleanup()

    def request(self, method, path, body=None):
        data = body if isinstance(body, bytes) or body is None else json.dumps(body).encode()
        req = urllib.request.Request(self.base + path, data=data, method=method)
        try:
            with urllib.request.urlopen(req) as resp:
                raw = resp.read()
                return resp.status, json.loads(raw) if raw else None
        except urllib.error.HTTPError as err:
            raw = err.read()
            return err.code, json.loads(raw) if raw else None

    def test_create_list_complete(self):
        status, body = self.request("POST", "/tasks", {"title": "Ship"})
        self.assertEqual(status, 201)
        task_id = body["id"]
        self.assertEqual(self.request("GET", "/tasks"), (200, [{"id": task_id, "title": "Ship", "done": False}]))
        self.assertEqual(self.request("POST", "/tasks/%d/complete" % task_id)[0], 204)
        self.assertTrue(self.request("GET", "/tasks")[1][0]["done"])

    def test_invalid_json(self):
        status, body = self.request("POST", "/tasks", b"{not json")
        self.assertEqual(status, 400)
        self.assertIn("error", body)

    def test_missing_title(self):
        status, body = self.request("POST", "/tasks", {"name": "x"})
        self.assertEqual(status, 400)
        self.assertIn("error", body)

    def test_complete_missing(self):
        self.assertEqual(self.request("POST", "/tasks/999/complete")[0], 404)

    def test_unknown_route(self):
        self.assertEqual(self.request("GET", "/nope")[0], 404)

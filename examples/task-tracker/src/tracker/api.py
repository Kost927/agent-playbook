"""JSON HTTP API.

GET  /tasks                -> 200 [{"id", "title", "done"}]
POST /tasks {"title": str} -> 201 {"id"}; 400 {"error"} on invalid input; 408 when the body is shorter than Content-Length
POST /tasks/<id>/complete  -> 204; 404 {"error"} when the task does not exist
"""
import json
import re
import socket
import threading
from http.server import BaseHTTPRequestHandler, HTTPServer

from tracker import db

COMPLETE_ROUTE = re.compile(r"^/tasks/(\d+)/complete$")


def make_handler(db_path: str, request_timeout: float = 5.0):
    """Build a handler bound to one store. Slow or truncated requests time out after request_timeout seconds."""
    conn = db.connect(db_path)
    lock = threading.Lock()

    class Handler(BaseHTTPRequestHandler):
        timeout = request_timeout

        def log_message(self, format, *args):
            pass

        def send_json(self, status, payload=None):
            body = b"" if payload is None else json.dumps(payload).encode()
            self.send_response(status)
            if body:
                self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        def do_GET(self):
            if self.path != "/tasks":
                return self.send_json(404, {"error": "not found"})
            with lock:
                tasks = db.list_tasks(conn)
            self.send_json(200, tasks)

        def do_POST(self):
            if self.path == "/tasks":
                return self.create_task()
            match = COMPLETE_ROUTE.match(self.path)
            if not match:
                return self.send_json(404, {"error": "not found"})
            try:
                with lock:
                    done = db.complete_task(conn, int(match.group(1)))
            except OverflowError:
                done = False
            self.send_json(204) if done else self.send_json(404, {"error": "task not found"})

        def create_task(self):
            try:
                length = int(self.headers.get("Content-Length") or 0)
            except ValueError:
                length = -1
            if length < 0:
                return self.send_json(400, {"error": "invalid Content-Length"})
            try:
                body = self.rfile.read(length)
            except socket.timeout:
                self.close_connection = True
                return self.send_json(408, {"error": "request body incomplete"})
            try:
                payload = json.loads(body or b"null")
            except (ValueError, RecursionError):
                return self.send_json(400, {"error": "body must be JSON"})
            title = payload.get("title") if isinstance(payload, dict) else None
            if not isinstance(title, str) or not title.strip():
                return self.send_json(400, {"error": "title is required"})
            with lock:
                task_id = db.add_task(conn, title.strip())
            self.send_json(201, {"id": task_id})

    return Handler


def serve(db_path: str = "tracker.db", port: int = 8000) -> None:
    HTTPServer(("127.0.0.1", port), make_handler(db_path)).serve_forever()


if __name__ == "__main__":
    serve()

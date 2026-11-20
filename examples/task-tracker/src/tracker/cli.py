"""Command-line interface: add, list, done."""
import argparse
import sys
from typing import List, Optional

from tracker import db


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(prog="tracker")
    parser.add_argument("--db", default="tracker.db", help="SQLite database path")
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("add").add_argument("title")
    commands.add_parser("list")
    commands.add_parser("done").add_argument("id", type=int)
    args = parser.parse_args(argv)

    conn = db.connect(args.db)
    try:
        if args.command == "add":
            title = args.title.strip()
            if not title:
                print("title must not be blank", file=sys.stderr)
                return 1
            print(db.add_task(conn, title))
        elif args.command == "list":
            for task in db.list_tasks(conn):
                print("[%s] %d %s" % ("x" if task["done"] else " ", task["id"], task["title"]))
        elif args.id > 2**63 - 1 or not db.complete_task(conn, args.id):
            print("task %d not found" % args.id, file=sys.stderr)
            return 1
        return 0
    finally:
        conn.close()


if __name__ == "__main__":
    sys.exit(main())

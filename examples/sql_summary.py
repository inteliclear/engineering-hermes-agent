# -*- coding: utf-8 -*-
"""
examples/sql_summary.py — Query PostgreSQL and summarize results.

Usage:
    python3 sql_summary.py --table users --columns id,email --limit 10
"""

import argparse
import json
import os
import sys
from urllib.parse import quote

try:
    import yaml
except ImportError:
    yaml = None  # optional


def main():
    parser = argparse.ArgumentParser(description="Query PostgreSQL and summarize")
    parser.add_argument("--table", default="users", help="Table to query")
    parser.add_argument("--columns", default="id,email", help="Comma-separated columns")
    parser.add_argument("--limit", type=int, default=10, help="Row limit")
    parser.add_argument("--output", choices=["json", "yaml", "text"], default="text")
    args = parser.parse_args()

    cols = args.columns.split(",")
    col_list = ", ".join(cols)
    query = f"SELECT {col_list} FROM {args.table} LIMIT {args.limit}"

    # Example results (replace with actual DB call)
    rows = [
        {"id": 1, "email": "alice@example.com"},
        {"id": 2, "email": "bob@example.com"},
    ]

    if args.output == "json":
        print(json.dumps(rows, indent=2))
    elif args.output == "yaml" and yaml:
        print(yaml.dump(rows, default_flow_style=False))
    else:
        # Table-like text output
        widths = {c: max(len(c), max((len(str(r.get(c))) for r in rows), default=0)) for c in cols}
        header = " | ".join(c.ljust(widths[c]) for c in cols)
        print(header)
        print("-" * len(header))
        for row in rows:
            line = " | ".join(str(row.get(c, "")).ljust(widths[c]) for c in cols)
            print(line)


if __name__ == "__main__":
    main()

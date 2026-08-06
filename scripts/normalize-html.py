#!/usr/bin/env python3
"""Normalize published HTML after Calepin rendering."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / "docs"


def main() -> int:
    changed = 0
    for path in sorted(SITE.rglob("*.html")):
        if any(part in {"theme", "_calepin", ".calepin"} for part in path.parts):
            continue
        source = path.read_text(encoding="utf-8")
        normalized = "\n".join(line.rstrip() for line in source.splitlines()) + "\n"
        if normalized != source:
            path.write_text(normalized, encoding="utf-8")
            changed += 1
    print(f"Published HTML normalization: PASS ({changed} files changed)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

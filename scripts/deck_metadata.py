#!/usr/bin/env python3
"""Read and validate the canonical complete-deck metadata manifest."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs-src/examples/decks/manifest.json"


def load_manifest() -> dict:
    data = json.loads(MANIFEST.read_text(encoding="utf-8"))
    if set(data) != {"decks", "showcase"}:
        raise ValueError("deck manifest requires exactly decks and showcase")
    decks = data.get("decks")
    if not isinstance(decks, list) or not decks:
        raise ValueError("deck manifest requires a non-empty decks array")
    seen: set[str] = set()
    for entry in decks:
        required = {"slug", "title", "frames", "alt"}
        if set(entry) != required:
            raise ValueError(f"deck entry keys must be {sorted(required)}: {entry!r}")
        slug = entry["slug"]
        if not isinstance(slug, str) or not slug or slug in seen:
            raise ValueError(f"deck slug must be unique and non-empty: {slug!r}")
        seen.add(slug)
        if not isinstance(entry["title"], str) or not entry["title"]:
            raise ValueError(f"deck {slug} requires a title")
        if not isinstance(entry["alt"], str) or not entry["alt"]:
            raise ValueError(f"deck {slug} requires alt text")
        if type(entry["frames"]) is not int or entry["frames"] < 1:
            raise ValueError(f"deck {slug} frames must be a positive integer")
        if not (ROOT / f"docs-src/examples/decks/{slug}/Makefile").is_file():
            raise ValueError(f"deck {slug} has no Makefile")
    directories = {
        path.parent.name
        for path in (ROOT / "docs-src/examples/decks").glob("*/Makefile")
    }
    if directories != seen:
        raise ValueError(
            f"deck manifest/directories differ: manifest={sorted(seen)}, directories={sorted(directories)}"
        )
    showcase = data["showcase"]
    if not isinstance(showcase, list) or not showcase:
        raise ValueError("showcase must be a non-empty array")
    for item in showcase:
        if not isinstance(item, dict) or set(item) != {"source", "pages"}:
            raise ValueError("showcase entries require exactly source and pages")
        source = item["source"]
        pages = item["pages"]
        if not isinstance(source, str) or not source.endswith(".pdf"):
            raise ValueError("showcase source must be a PDF path")
        if not isinstance(pages, list) or not pages:
            raise ValueError(f"showcase entry needs at least one page: {source}")
        for page in pages:
            # A nested array is one incremental build: its steps play fast and
            # only the completed final step is held.
            run = page if isinstance(page, list) else [page]
            if isinstance(page, list) and len(run) < 2:
                raise ValueError(f"showcase build needs at least two steps: {source}")
            if any(type(step) is not int or step < 1 for step in run):
                raise ValueError(f"showcase pages must be positive integers: {source}")
        flat = flatten_pages(pages)
        if len(flat) != len(set(flat)):
            raise ValueError(f"showcase pages must be unique: {source}")
    return data


def flatten_pages(pages: list) -> list[int]:
    return [step for page in pages for step in (page if isinstance(page, list) else [page])]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=("check", "slugs", "showcase"))
    args = parser.parse_args()
    data = load_manifest()
    if args.command == "slugs":
        print(" ".join(entry["slug"] for entry in data["decks"]))
    elif args.command == "showcase":
        # Each line is source|page|kind. A "step" is one frame of an
        # incremental build; a "beat" is a slide the reel rests on.
        for item in data["showcase"]:
            for page in item["pages"]:
                run = page if isinstance(page, list) else [page]
                for step in run[:-1]:
                    print(f'{item["source"]}|{step}|step')
                print(f'{item["source"]}|{run[-1]}|beat')
    else:
        print(f'Deck manifest: PASS ({len(data["decks"])} decks)')
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

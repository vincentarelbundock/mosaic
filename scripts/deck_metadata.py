#!/usr/bin/env python3
"""Read and validate the canonical complete-deck metadata manifest."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs/examples/decks/manifest.json"


def load_manifest() -> dict:
    data = json.loads(MANIFEST.read_text(encoding="utf-8"))
    if set(data) != {"decks", "showcase_intro"}:
        raise ValueError("deck manifest requires exactly decks and showcase_intro")
    decks = data.get("decks")
    if not isinstance(decks, list) or not decks:
        raise ValueError("deck manifest requires a non-empty decks array")
    seen: set[str] = set()
    for entry in decks:
        required = {"slug", "title", "frames", "alt", "showcase_pages"}
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
        frames = entry["frames"]
        pages = entry["showcase_pages"]
        if type(frames) is not int or frames < 1:
            raise ValueError(f"deck {slug} frames must be a positive integer")
        if not isinstance(pages, list) or any(
            type(page) is not int or page < 1 or page > frames for page in pages
        ):
            raise ValueError(f"deck {slug} showcase pages must be within 1..{frames}")
        if len(pages) != len(set(pages)):
            raise ValueError(f"deck {slug} showcase pages must be unique")
        if not (ROOT / f"docs/examples/decks/{slug}/Makefile").is_file():
            raise ValueError(f"deck {slug} has no Makefile")
    directories = {
        path.parent.name
        for path in (ROOT / "docs/examples/decks").glob("*/Makefile")
    }
    if directories != seen:
        raise ValueError(
            f"deck manifest/directories differ: manifest={sorted(seen)}, directories={sorted(directories)}"
        )
    intro = data["showcase_intro"]
    if not isinstance(intro, list):
        raise ValueError("showcase_intro must be an array")
    for item in intro:
        if not isinstance(item, dict) or set(item) != {"source", "pages"}:
            raise ValueError("showcase intro entries require exactly source and pages")
        source = item["source"]
        pages = item["pages"]
        if not isinstance(source, str) or not source.endswith(".pdf"):
            raise ValueError("showcase intro source must be a PDF path")
        if not isinstance(pages, list) or not pages or any(type(page) is not int or page < 1 for page in pages):
            raise ValueError(f"showcase intro pages must be positive integers: {source}")
        if len(pages) != len(set(pages)):
            raise ValueError(f"showcase intro pages must be unique: {source}")
    return data


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=("check", "slugs", "showcase"))
    args = parser.parse_args()
    data = load_manifest()
    if args.command == "slugs":
        print(" ".join(entry["slug"] for entry in data["decks"]))
    elif args.command == "showcase":
        for item in data.get("showcase_intro", []):
            for page in item["pages"]:
                print(f'{item["source"]}|{page}')
        for entry in data["decks"]:
            source = f'docs/examples/decks/{entry["slug"]}/{entry["slug"]}.pdf'
            for page in entry["showcase_pages"]:
                print(f"{source}|{page}")
    else:
        print(f'Deck manifest: PASS ({len(data["decks"])} decks)')
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

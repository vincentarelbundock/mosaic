#!/usr/bin/env python3
"""Validate documentation sources, rendered assets, deck metadata, and site links."""

from __future__ import annotations

import argparse
import importlib.util
import re
import subprocess
import sys
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit

from PIL import Image

from deck_metadata import load_manifest  # type: ignore[import-not-found]
from embedded_examples import ExampleCall, parse_calls

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
SOURCES = DOCS / "examples/embedded"
ASSETS = DOCS / "assets/examples"
GREYSCALE_DECK = DOCS / "examples/decks/portfolio"


class IntegrityError(RuntimeError):
    pass


def authored_pages() -> list[Path]:
    return sorted(
        path for path in DOCS.rglob("*.typ")
        if not any(part in {"_calepin", ".calepin", "examples", "api"} for part in path.parts)
    ) + sorted((DOCS / "api").glob("*.typ"))


def source_slugs() -> set[str]:
    return {
        path.relative_to(SOURCES).with_suffix("").as_posix()
        for path in SOURCES.rglob("*.typ")
        if not path.name.startswith("_")
    }


def padded(page: int, total: int) -> str:
    return str(page).zfill(len(str(total)))


def expected_assets(call: ExampleCall) -> set[Path]:
    base = ASSETS / call.slug
    if call.renderer == "slideshow":
        return {base.with_suffix(".pdf"), Path(str(base) + "-cover.svg")}
    last = call.start + call.frames - 1
    return {base.with_suffix(".pdf")} | {
        Path(str(base) + f"-{padded(page, last)}.svg")
        for page in range(call.start, last + 1)
    }


def pdf_pages(path: Path) -> int:
    result = subprocess.run(["pdfinfo", str(path)], text=True, capture_output=True)
    if result.returncode:
        raise IntegrityError(f"pdfinfo failed for {path}: {result.stderr.strip()}")
    match = re.search(r"^Pages:\s+(\d+)\s*$", result.stdout, re.MULTILINE)
    if not match:
        raise IntegrityError(f"could not read PDF page count: {path}")
    return int(match.group(1))


def check_greyscale_theme(manifest: dict, errors: list[str]) -> None:
    entry = next((item for item in manifest["decks"] if item["slug"] == "portfolio"), None)
    if entry is None or entry["title"] != "Greyscale":
        errors.append('portfolio deck must be presented as the "Greyscale" theme')

    for path in sorted((GREYSCALE_DECK / "assets").glob("*.png")):
        red, green, blue = Image.open(path).convert("RGB").split()
        if red.tobytes() != green.tobytes() or green.tobytes() != blue.tobytes():
            errors.append(f"greyscale theme contains a color image: {path.relative_to(ROOT)}")


def check_sources() -> tuple[list[ExampleCall], set[Path]]:
    pages = authored_pages()
    calls = parse_calls(pages)
    sources = source_slugs()
    consumers = [call.slug for call in calls]
    authored_text = "\n".join(path.read_text(encoding="utf-8") for path in pages)
    manual_consumers = {
        slug for slug in sources
        if slug not in consumers and slug in authored_text
    }
    consumer_set = set(consumers) | manual_consumers
    errors: list[str] = []
    if sources - consumer_set:
        errors.append(f"embedded sources without consumers: {sorted(sources - consumer_set)}")
    if consumer_set - sources:
        errors.append(f"embedded consumers without sources: {sorted(consumer_set - sources)}")
    duplicates = sorted(slug for slug in set(consumers) if consumers.count(slug) != 1)
    if duplicates:
        errors.append(f"embedded slugs must have one consumer: {duplicates}")

    expected: set[Path] = set()
    for call in calls:
        assets = expected_assets(call)
        expected.update(assets)
        missing = sorted(path.relative_to(ROOT).as_posix() for path in assets if not path.is_file())
        if missing:
            errors.append(f"{call.slug} missing generated assets: {missing}")
        if call.renderer == "slideshow":
            pdf = ASSETS / f"{call.slug}.pdf"
            if pdf.is_file() and pdf_pages(pdf) != call.frames:
                errors.append(f"{call.slug} PDF frame count differs from declared {call.frames}")

    # Some explanatory pages intentionally select individual frames from one
    # multi-composition producer instead of using embedded-example(). The build
    # deletes that producer's old SVGs before compiling it, so its current
    # slug-prefixed files are the complete, non-stale output set.
    for slug in manual_consumers:
        base = ASSETS / slug
        produced = set(base.parent.glob(base.name + "-*.svg"))
        if not produced:
            errors.append(f"{slug} has no generated SVG assets")
        pdf = base.with_suffix(".pdf")
        if not pdf.is_file():
            errors.append(f"{slug} has no generated PDF")
        expected.update(produced | {pdf})

    actual = {
        path for path in ASSETS.rglob("*")
        if path.is_file() and path.suffix in {".pdf", ".svg"}
    }
    stale = sorted(path.relative_to(ROOT).as_posix() for path in actual - expected)
    if stale:
        errors.append(f"stale embedded assets: {stale}")

    manifest = load_manifest()
    check_greyscale_theme(manifest, errors)
    for item in manifest["showcase_intro"]:
        source = ROOT / item["source"]
        if not source.is_file():
            errors.append(f"showcase intro source is missing: {item['source']}")
        elif (pages := pdf_pages(source)) < max(item["pages"]):
            errors.append(
                f"showcase intro selects page {max(item['pages'])} from "
                f"a {pages}-page PDF: {item['source']}"
            )
    for entry in manifest["decks"]:
        directory = DOCS / f'examples/decks/{entry["slug"]}'
        pdf = directory / f'{entry["slug"]}.pdf'
        cover = directory / "cover.jpg"
        if not pdf.is_file() or not cover.is_file():
            errors.append(f'deck {entry["slug"]} is missing its PDF or cover')
        elif pdf_pages(pdf) != entry["frames"]:
            errors.append(
                f'deck {entry["slug"]} has {pdf_pages(pdf)} pages; manifest declares {entry["frames"]}'
            )

    if errors:
        raise IntegrityError("\n".join(errors))
    print(f"Embedded examples: PASS ({len(sources)} sources, {len(calls)} consumers)")
    print(f"Rendered assets: PASS ({len(expected)} files)")
    print(f"Complete decks: PASS ({len(manifest['decks'])} decks)")
    return calls, expected


class DocumentParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.ids: set[str] = set()
        self.urls: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        values = dict(attrs)
        if values.get("id"):
            self.ids.add(values["id"] or "")
        for key in ("href", "src"):
            if values.get(key):
                self.urls.append(values[key] or "")


def check_site() -> None:
    html_files = sorted(
        path for path in DOCS.rglob("*.html")
        if "_calepin" not in path.parts
        and ".calepin" not in path.parts
        and "theme" not in path.parts
    )
    parsed: dict[Path, DocumentParser] = {}
    for path in html_files:
        parser = DocumentParser()
        parser.feed(path.read_text(encoding="utf-8", errors="replace"))
        parsed[path.resolve()] = parser

    errors: list[str] = []
    for page, parser in parsed.items():
        for raw in parser.urls:
            parts = urlsplit(raw)
            if parts.scheme or parts.netloc or raw.startswith(("mailto:", "tel:", "data:")):
                continue
            local = unquote(parts.path)
            target = page if not local else ((DOCS / local.lstrip("/")) if local.startswith("/") else (page.parent / local))
            target = target.resolve()
            if target.is_dir():
                target = target / "index.html"
            if not target.exists():
                errors.append(f"{page.relative_to(ROOT)}: broken local URL {raw!r}")
                continue
            if parts.fragment and target.suffix == ".html":
                target_parser = parsed.get(target)
                if target_parser is None:
                    target_parser = DocumentParser()
                    target_parser.feed(target.read_text(encoding="utf-8", errors="replace"))
                    parsed[target] = target_parser
                if parts.fragment not in target_parser.ids:
                    errors.append(f"{page.relative_to(ROOT)}: missing anchor {raw!r}")
    if errors:
        raise IntegrityError("\n".join(errors))
    print(f"Website links: PASS ({len(html_files)} HTML pages)")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--site", action="store_true", help="also validate generated HTML links and anchors")
    args = parser.parse_args()
    check_sources()
    if args.site:
        check_site()
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (IntegrityError, ValueError) as error:
        print(f"documentation integrity failure:\n{error}", file=sys.stderr)
        raise SystemExit(1)

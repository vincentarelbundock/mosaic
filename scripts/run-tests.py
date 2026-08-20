#!/usr/bin/env python3
"""Run Mosaic's explicit positive and negative test manifests."""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TESTS = ROOT / "tests"
TMP = Path(os.environ.get("TMPDIR", "/tmp"))


class TestFailure(RuntimeError):
    pass


def command(args: list[str], *, capture: bool = False) -> subprocess.CompletedProcess[str]:
    print(" ".join(args), flush=True)
    result = subprocess.run(
        args,
        cwd=ROOT,
        text=True,
        capture_output=capture,
    )
    if result.returncode != 0:
        if capture:
            sys.stderr.write(result.stdout)
            sys.stderr.write(result.stderr)
        raise TestFailure(f"command failed ({result.returncode}): {' '.join(args)}")
    return result


def require_contains(path: Path, needle: str, *, count: int | None = None, absent: bool = False) -> None:
    text = path.read_text(encoding="utf-8", errors="replace")
    actual = text.count(needle)
    if absent and actual:
        raise TestFailure(f"{path} unexpectedly contains {needle!r}")
    if count is not None and actual != count:
        raise TestFailure(f"{path} contains {needle!r} {actual} times, expected {count}")
    if not absent and count is None and actual == 0:
        raise TestFailure(f"{path} does not contain {needle!r}")


def require_same_line(path: Path, first: str, second: str) -> None:
    """Require both needles on one line, which in a -layout extraction means
    they share a baseline on the page."""
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        if first in line and second in line:
            return
    raise TestFailure(f"{path} has no line holding both {first!r} and {second!r}")


def typst_compile(typst: str, source: str, output: Path, *extra: str) -> None:
    command([typst, "compile", "--root", ".", *extra, f"tests/{source}", str(output)])


def manifest() -> dict[str, list[str]]:
    data = json.loads((TESTS / "positive-manifest.json").read_text(encoding="utf-8"))
    listed = set(data["core"] + data["layout"] + data["responsive"])
    actual = {path.name for path in TESTS.glob("*.typ")}
    if listed != actual:
        raise TestFailure(
            f"positive manifest mismatch: missing={sorted(actual - listed)}, stale={sorted(listed - actual)}"
        )
    return data


def compile_group(typst: str, sources: list[str]) -> None:
    for source in sources:
        typst_compile(typst, source, TMP / f"mosaic-{Path(source).stem}.pdf")


def pdf_text(stem: str) -> Path:
    source = TMP / f"mosaic-{stem}.pdf"
    target = TMP / f"mosaic-{stem}.txt"
    command(["pdftotext", "-layout", str(source), str(target)])
    return target


def pdf_page_text(stem: str, page: int) -> Path:
    source = TMP / f"mosaic-{stem}.pdf"
    target = TMP / f"mosaic-{stem}-page-{page}.txt"
    command([
        "pdftotext", "-layout", "-f", str(page), "-l", str(page),
        str(source), str(target),
    ])
    return target


def pdf_info(stem: str) -> Path:
    source = TMP / f"mosaic-{stem}.pdf"
    target = TMP / f"mosaic-{stem}-pdfinfo.txt"
    result = command(["pdfinfo", str(source)], capture=True)
    target.write_text(result.stdout, encoding="utf-8")
    return target


def pdf_attachment(stem: str, name: str) -> str:
    """The text of one embedded file, extracted by name.

    `pdfdetach` comes from the same poppler package as `pdftotext`, so the
    attachment assertions cost the suite no prerequisite it did not already
    have. Extraction is by name rather than by index: the check is that Mosaic
    named the file what a console looks for, not that it happened to be first.
    """
    source = TMP / f"mosaic-{stem}.pdf"
    target = TMP / f"mosaic-{stem}-{name}"
    command(["pdfdetach", "-savefile", name, "-o", str(target), str(source)])
    return target.read_text(encoding="utf-8")


def run_core(typst: str, sources: list[str]) -> None:
    compile_group(typst, sources)

    typst_compile(typst, "setup-native-defaults.typ", TMP / "mosaic-setup-native-defaults-{0p}.svg", "--format", "svg")
    native = TMP / "mosaic-setup-native-defaults-1.svg"
    require_contains(native, "#f8f8f7")
    require_contains(native, "#18181b")

    deck_metadata = pdf_text("setup-deck-metadata")
    for expected in (
        "INHERITED TITLE", "INHERITED SUBTITLE", "Ada Lovelace",
        "Platform Engineering", "INHERITED DATE", "EXPLICIT TITLE",
    ):
        require_contains(deck_metadata, expected)
    explicit_title = pdf_page_text("setup-deck-metadata", 2)
    for inherited in ("INHERITED SUBTITLE", "Ada Lovelace", "INHERITED DATE"):
        require_contains(explicit_title, inherited, absent=True)
    deck_info = pdf_info("setup-deck-metadata")
    require_contains(deck_info, "Title:           INHERITED TITLE")
    require_contains(deck_info, "Author:          Ada Lovelace")
    typst_compile(
        typst,
        "setup-deck-metadata.typ",
        TMP / "mosaic-setup-deck-metadata-{0p}.svg",
        "--format",
        "svg",
    )
    inherited_title = TMP / "mosaic-setup-deck-metadata-1.svg"
    require_contains(inherited_title, "#f5f7fb")
    require_contains(inherited_title, "#7c3aed")

    content_defaults = pdf_text("setup-cells-defaults")
    require_contains(content_defaults, "SETUP FOOTER", count=2)
    for expected in ("FULL FOOTER", "NAMED FOOTER", "BODY ONLY"):
        require_contains(content_defaults, expected)
    for page in (1, 3):
        require_contains(pdf_page_text("setup-cells-defaults", page), "SETUP FOOTER")
    require_contains(pdf_page_text("setup-cells-defaults", 2), "FULL FOOTER")
    require_contains(pdf_page_text("setup-cells-defaults", 2), "SETUP FOOTER", absent=True)
    require_contains(pdf_page_text("setup-cells-defaults", 4), "NAMED FOOTER")
    for page in (5, 6):
        page_text = pdf_page_text("setup-cells-defaults", page)
        for footer in ("SETUP FOOTER", "FULL FOOTER", "NAMED FOOTER"):
            require_contains(page_text, footer, absent=True)

    plane_defaults = pdf_text("setup-plane-defaults")
    for expected in ("SETUP BACKGROUND", "SETUP LOGO"):
        require_contains(plane_defaults, expected, count=2)
    for expected in ("LOCAL BACKGROUND", "LOCAL FOREGROUND"):
        require_contains(plane_defaults, expected, count=1)
    require_contains(
        pdf_page_text("setup-plane-defaults", 2),
        "SETUP LOGO",
    )

    typst_compile(typst, "image.typ", TMP / "mosaic-image-{0p}.svg", "--format", "svg")
    image = TMP / "mosaic-image-1.svg"
    require_contains(image, "#00000059")
    require_contains(image, "#ffffff33")
    # A scrim takes any paint, so a gradient reaches the page unflattened.
    require_contains(image, "linearGradient")

    # The figure component's `height: auto` gives adjacent captions one baseline
    # whatever the pictures' aspect ratios, which is the whole reason a
    # hand-found matching height had to be tuned per slide.
    figure_pair = pdf_page_text("figure", 1)
    require_same_line(figure_pair, "PORTRAIT CAPTION", "LANDSCAPE CAPTION")
    figure_prose = pdf_page_text("figure", 2)
    for expected in ("INLINE CAPTION", "FULL CELL CAPTION"):
        require_contains(figure_prose, expected)

    # A quote credit sets its comma tight against the attribution: the three
    # branches join in code mode, where no markup newline can slip a space in.
    require_contains(pdf_page_text("components", 1), "Author, Source")

    typst_compile(
        typst,
        "theme-dark.typ",
        TMP / "mosaic-theme-dark-{0p}.svg",
        "--format",
        "svg",
    )
    dark_pages = [TMP / f"mosaic-theme-dark-{page}.svg" for page in (1, 2, 3)]
    for page in dark_pages:
        require_contains(page, "#16181b")
        require_contains(page, "#f2f2f0")
        for light_color in ("#f8f8f7", "#18181b", "#4a6274", "#737373", "#e3e3e0"):
            require_contains(page, light_color, absent=True)
    # The ruled title draws its rule in the palette accent, and the
    # accent-role progress line on later pages proves the same flow.
    require_contains(dark_pages[1], "#7e97ad")
    # "#182434" is the accent role's panel fill: the accent tinted into the
    # dark canvas, derived rather than stored in a per-theme table. The
    # remaining values are the dark syntax theme, which the light theme swaps
    # in on its own once the palette's canvas reads as dark.
    for dark_color in ("#24292e", "#d2a8ff", "#ff7b72", "#ffa657"):
        require_contains(dark_pages[1], dark_color)

    typst_compile(
        typst,
        "theme-dark-components.typ",
        TMP / "mosaic-theme-dark-components-{0p}.svg",
        "--format",
        "svg",
    )
    dark_components = TMP / "mosaic-theme-dark-components-1.svg"
    # Role accents come straight from Dark's flat palette; the "#24"/"#2a"/"#2c"
    # fills are those accents tinted into its canvas.
    for dark_color in (
        "#1e2125", "#24292e", "#2a2925", "#2c2728",
        "#7e97ad", "#bc8cff", "#b39a5f", "#c08476",
    ):
        require_contains(dark_components, dark_color)
    for light_color in ("#f8f8f7", "#18181b", "#4a6274", "#737373", "#e3e3e0"):
        require_contains(dark_components, light_color, absent=True)

    typst_compile(
        typst,
        "theme-definition.typ",
        TMP / "mosaic-theme-definition-{0p}.svg",
        "--format",
        "svg",
    )
    passive_body = TMP / "mosaic-theme-definition-2.svg"
    require_contains(passive_body, "#a23b72")
    require_contains(passive_body, "#0072b2", absent=True)

    frozen = pdf_text("frozen-state")
    require_contains(frozen, "Reveal: frozen 1/1", count=2)
    require_contains(frozen, "On: frozen 2/2", count=2)
    require_contains(frozen, "Replace: frozen 3/3", count=2)
    for expected in (
        "Reveal: frozen 1/1 native 1/1",
        "Reveal: frozen 1/1 native 2/2",
        "On: frozen 2/2 native 3/3",
        "On: frozen 2/2 native 4/4",
        "Replace: frozen 3/3 native 5/5",
        "Replace: frozen 3/3 native 6/6",
        "Final: frozen 3/3 native 6/6.",
    ):
        require_contains(frozen, expected)

    handout = pdf_text("handout")
    for expected in (
        "REPLACE FINAL",
        "HANDOUT FINAL FRAME",
        "REVEAL FIRST",
        "REVEAL FINAL",
        "ON BASE ON FINAL",
        "REDUCER BASE | REDUCER FINAL",
        "BACKGROUND",
        "FOREGROUND FINAL",
        "STATIC FINAL: frozen 1/1 native 1/1.",
    ):
        require_contains(handout, expected)
    for forbidden in ("REPLACE FIRST", "BACKGROUND FIRST", "FOREGROUND FIRST"):
        require_contains(handout, forbidden, absent=True)

    handout_off = pdf_text("handout-off")
    for expected in ("ORDINARY FIRST", "ORDINARY FINAL"):
        require_contains(handout_off, expected)

    speaker_slides = pdf_text("speaker-notes-output")
    for forbidden in ("GENERAL OUTPUT NOTE", "FIRST FRAME NOTE", "SECOND FRAME NOTE"):
        require_contains(speaker_slides, forbidden, absent=True)
    for expected in ("FIRST VISUAL", "SECOND VISUAL"):
        require_contains(speaker_slides, expected)

    drawing_text = pdf_text("speaker-notes-drawing")
    require_contains(drawing_text, "VISIBLE DRAWING FRAME")
    require_contains(drawing_text, "DRAWING SLOT", absent=True)
    require_contains(drawing_text, "DRAWING SECRET NOTE", absent=True)
    require_contains(drawing_text, "NESTED DRAWING SECRET NOTE", absent=True)
    metadata_show_text = pdf_text("speaker-notes-metadata-show")
    require_contains(metadata_show_text, "VISIBLE CONTENT")
    require_contains(metadata_show_text, "NESTED SECRET NOTE", absent=True)
    require_contains(metadata_show_text, "speaker-notes", absent=True)

    # The embedded pdfpc payload. Asserted as parsed JSON rather than as a
    # substring because the contract is the mapping — which physical page each
    # note lands on — and a grep would pass on a payload that had every note
    # under the wrong page.
    embedded = json.loads(pdf_attachment("speaker-notes-embed", "speaker-notes.pdfpc"))
    if embedded["pdfpcFormat"] != 2:
        raise TestFailure(f"embedded pdfpc format: {embedded['pdfpcFormat']}")
    notes = {page["idx"]: page["note"] for page in embedded["pages"]}
    if sorted(notes) != [1, 4, 5]:
        raise TestFailure(f"embedded pdfpc pages: {sorted(notes)}")
    if notes[1] != "EMBED FIRST NOTE":
        raise TestFailure(f"embedded note on page 1: {notes[1]!r}")
    # The frame's own note, on the frame rather than on the slide's first page.
    if notes[4] != "EMBED FRAME NOTE":
        raise TestFailure(f"embedded note on page 4: {notes[4]!r}")
    if notes[5] != "EMBED PAIR ONE\n\nEMBED PAIR TWO":
        raise TestFailure(f"embedded notes on page 5: {notes[5]!r}")

    # A deck with no notes carries no attachment, so `pdfdetach` finds nothing
    # to list. The payload is not an empty file the reader must then interpret.
    bare = command(
        ["pdfdetach", "-list", str(TMP / "mosaic-setup-native-defaults.pdf")],
        capture=True,
    )
    if "0 embedded files" not in bare.stdout:
        raise TestFailure(f"a deck without notes carries an attachment: {bare.stdout!r}")

    pause_pages = [pdf_page_text("pause", page) for page in (1, 2, 3)]
    require_contains(pause_pages[0], "PAUSE FIRST")
    require_contains(pause_pages[0], "PAUSE SECOND", absent=True)
    require_contains(pause_pages[0], "PAUSE THIRD", absent=True)
    require_contains(pause_pages[1], "PAUSE FIRST")
    require_contains(pause_pages[1], "PAUSE SECOND")
    require_contains(pause_pages[1], "PAUSE THIRD", absent=True)
    for expected in ("PAUSE FIRST", "PAUSE SECOND", "PAUSE THIRD"):
        require_contains(pause_pages[2], expected)

    compose_pages = [pdf_page_text("pause-compose", page) for page in (1, 2, 3)]
    require_contains(compose_pages[0], "COMPOSE FIRST")
    require_contains(compose_pages[0], "COMPOSE SECOND", absent=True)
    require_contains(compose_pages[1], "COMPOSE SECOND")
    require_contains(compose_pages[1], "COMPOSE THIRD", absent=True)
    require_contains(compose_pages[2], "COMPOSE THIRD")

    nested_first = pdf_page_text("pause-nested", 1)
    nested_second = pdf_page_text("pause-nested", 2)
    require_contains(nested_first, "NESTED FIRST")
    require_contains(nested_first, "NESTED SECOND", absent=True)
    require_contains(nested_second, "NESTED SECOND")

    fixed_first = pdf_page_text("pause-fixed-grid", 1)
    fixed_second = pdf_page_text("pause-fixed-grid", 2)
    require_contains(fixed_first, "FIXED PAUSE FIRST")
    require_contains(fixed_first, "FIXED PAUSE SECOND", absent=True)
    require_contains(fixed_second, "FIXED PAUSE SECOND")

    empty_markers = pdf_text("pause-empty-markers")
    require_contains(empty_markers, "EMPTY MARKER VISUAL")
    require_contains(empty_markers, "pause", absent=True)
    require_contains(pdf_info("pause-empty-markers"), "Pages:           1")

    # Whitespace-normalized: the phrases are one wrapped paragraph, so a line
    # break may fall inside any of them depending on the theme's tokens.
    pause_handout_text = " ".join(
        pdf_text("pause-handout").read_text(encoding="utf-8", errors="replace").split()
    )
    for expected in (
        "PAUSE HANDOUT FIRST",
        "PAUSE HANDOUT SECOND",
        "PAUSE HANDOUT FINAL",
    ):
        if expected not in pause_handout_text:
            raise TestFailure(f"pause-handout text does not contain {expected!r}")
    require_contains(pdf_info("pause-handout"), "Pages:           1")

    themed_text = pdf_text("speaker-notes-theme")
    require_contains(themed_text, "Themed speaker slide")
    require_contains(themed_text, "THEMED SPEAKER NOTE")
    themed_info = pdf_info("speaker-notes-theme")
    require_contains(themed_info, "Pages:           1")
    require_contains(themed_info, "595.276 x 841.89 pts (A4)")
    typst_compile(
        typst,
        "speaker-notes-theme.typ",
        TMP / "mosaic-speaker-notes-theme-{0p}.svg",
        "--format",
        "svg",
    )
    themed_svg = TMP / "mosaic-speaker-notes-theme-1.svg"
    require_contains(themed_svg, "#23373b")
    require_contains(themed_svg, "#fafafa")

    for output in ("speaker", "notes"):
        typst_compile(
            typst,
            "speaker-notes-output.typ",
            TMP / f"mosaic-{output}-output.pdf",
            "--input",
            f"output={output}",
        )
    speaker_first = pdf_page_text("speaker-output", 1)
    speaker_second = pdf_page_text("speaker-output", 2)
    for expected in ("FIRST VISUAL", "GENERAL OUTPUT NOTE", "FIRST FRAME NOTE"):
        require_contains(speaker_first, expected)
    for forbidden in ("SECOND VISUAL", "SECOND FRAME NOTE"):
        require_contains(speaker_first, forbidden, absent=True)
    for expected in (
        "FIRST VISUAL", "SECOND VISUAL", "GENERAL OUTPUT NOTE",
        "FIRST FRAME NOTE", "SECOND FRAME NOTE",
    ):
        require_contains(speaker_second, expected)

    # The note body renders at the deck's own weight in every printed output.
    # The frame heading above it is bold, and its label once leaked that weight
    # into the notes on the `notes` and `split` pages but not on `speaker`.
    require_contains(speaker_first, 'weight="regular"')

    notes_first = pdf_page_text("notes-output", 1)
    notes_second = pdf_page_text("notes-output", 2)
    for stem in ("speaker-output", "notes-output"):
        info = pdf_info(stem)
        require_contains(info, "Pages:           2")
        require_contains(info, "595.276 x 841.89 pts (A4)")
    for page in (notes_first, notes_second):
        for forbidden in ("FIRST VISUAL", "SECOND VISUAL"):
            require_contains(page, forbidden, absent=True)
    for expected in ("GENERAL OUTPUT NOTE", "FIRST FRAME NOTE"):
        require_contains(notes_first, expected)
    require_contains(notes_first, "SECOND FRAME NOTE", absent=True)
    require_contains(notes_first, 'weight="regular"')
    for expected in ("GENERAL OUTPUT NOTE", "FIRST FRAME NOTE", "SECOND FRAME NOTE"):
        require_contains(notes_second, expected)

    for output in ("speaker", "notes"):
        typst_compile(
            typst,
            "speaker-notes-handout.typ",
            TMP / f"mosaic-{output}-handout.pdf",
            "--input",
            f"output={output}",
        )
    speaker_handout = pdf_text("speaker-handout")
    for expected in (
        "FINAL HANDOUT FRAME", "GENERAL HANDOUT NOTE",
        "FIRST HANDOUT NOTE", "FINAL HANDOUT NOTE", "Frame 2 of 2",
    ):
        require_contains(speaker_handout, expected)
    notes_handout = pdf_text("notes-handout")
    for stem in ("speaker-handout", "notes-handout"):
        info = pdf_info(stem)
        require_contains(info, "Pages:           1")
        require_contains(info, "595.276 x 841.89 pts (A4)")
    require_contains(notes_handout, "FINAL HANDOUT FRAME", absent=True)
    for expected in (
        "GENERAL HANDOUT NOTE", "FIRST HANDOUT NOTE",
        "FINAL HANDOUT NOTE", "Frame 2 of 2",
    ):
        require_contains(notes_handout, expected)

    # The `split` output is recognized by presenter tools on geometry alone:
    # pympress takes any page wider than 2:1 as slide-plus-notes and pdfpc cuts
    # at the midpoint, so the page must be exactly twice the slide wide and the
    # notes must land on the right of that cut.
    typst_compile(
        typst,
        "speaker-notes-output.typ",
        TMP / "mosaic-split-output.pdf",
        "--input",
        "output=split",
    )
    split_info = pdf_info("split-output")
    require_contains(split_info, "Pages:           2")
    require_contains(split_info, "1683.78 x 473.563 pts")
    split_first = pdf_page_text("split-output", 1)
    for expected in ("FIRST VISUAL", "GENERAL OUTPUT NOTE", "FIRST FRAME NOTE"):
        require_contains(split_first, expected)
    require_contains(split_first, "SECOND FRAME NOTE", absent=True)
    require_contains(split_first, 'weight="regular"')
    require_contains(pdf_page_text("split-output", 2), "SECOND FRAME NOTE")

    query = [typst, "eval", "--root", ".", "query(<mosaic-overflow-warning>).len()", "--in"]
    warning_count = command(query + ["tests/overflow-warning.typ"], capture=True).stdout.strip()
    if warning_count != "2":
        raise TestFailure(f"expected two overflow warnings, got {warning_count!r}")
    values = command(
        [typst, "eval", "--root", ".", "query(<mosaic-overflow-warning>).map(it => it.value)", "--in", "tests/overflow-warning.typ"],
        capture=True,
    ).stdout
    warning_json = TMP / "mosaic-overflow-warning.json"
    warning_json.write_text(values, encoding="utf-8")
    for expected in ('"logical-slide":2', '"frame":1', '"frame":2', '"cell":"body"', "mosaic: content overflows cell"):
        require_contains(warning_json, expected)
    off_count = command(query + ["tests/overflow-off.typ"], capture=True).stdout.strip()
    if off_count != "0":
        raise TestFailure(f"expected no disabled overflow warnings, got {off_count!r}")
    typst_compile(typst, "overflow-warning.typ", TMP / "mosaic-overflow-warning-{0p}.svg", "--format", "svg")
    for path in TMP.glob("mosaic-overflow-warning-*.svg"):
        require_contains(path, 'transform="scale(', absent=True)

    # The section layouts fit content they generate themselves, so they scale
    # into their allocation and warn about nothing. The control slide is an
    # ordinary body cell, which has no fitter and does overflow, so the only
    # warning must name it: that is what proves the fitters ran.
    fit_values = command(
        [typst, "eval", "--root", ".", "query(<mosaic-overflow-warning>).map(it => it.value.cell)", "--in", "tests/fit-cells.typ"],
        capture=True,
    ).stdout.strip()
    if fit_values != '["body"]':
        raise TestFailure(f"expected only the unfitted control cell to overflow, got {fit_values!r}")

    # The automatic section tagline reaches the configured section layout.
    tagline = pdf_text("headings-section-tagline")
    require_contains(tagline, "SECTION TAGLINE")

    # The Metropolis section layout is a raw grid: its automatic tagline
    # renders in the section cell instead of a subtitle field.
    require_contains(pdf_text("theme-metropolis-tagline"), "SECTION TAGLINE METRO")

    # A header-less content layout still receives the automatic heading; it
    # folds into the body flow.
    fold = pdf_text("headings-cell-fold")
    require_contains(fold, "Folded Title")
    require_contains(fold, "FOLDED BODY")

    # The untimed aside inside a revealed list rides along on every frame.
    for page in (1, 2):
        require_contains(pdf_page_text("reveal-untimed-siblings", page), "UNTIMED ASIDE")

    # A note alone between two pauses survives into the notes output.
    require_contains(pdf_text("pause-note-segment"), "PAUSE SEGMENT NOTE")

    # Wrapper prefixes are matched by identity: the styled sibling keeps its
    # blue and the heading keeps its red.
    typst_compile(typst, "headings-styled-siblings.typ", TMP / "mosaic-headings-styled-siblings-{p}.svg", "--format", "svg")
    styled = TMP / "mosaic-headings-styled-siblings-1.svg"
    require_contains(styled, "#ff4136")
    require_contains(styled, "#0074d9")

    # Inverted slides knock the type out in the canvas color even where the
    # theme pins a cell-label fill (the Metropolis title) and inside
    # components, whose colors resolve from the inverted palette.
    typst_compile(typst, "slide-invert-cells.typ", TMP / "mosaic-slide-invert-cells-{p}.svg", "--format", "svg")
    for page in (1, 2):
        require_contains(TMP / f"mosaic-slide-invert-cells-{page}.svg", "#fafafa")

    section = pdf_text("section-counter")
    require_contains(section, "1/2")
    require_contains(section, "2/2")


def run_layout(typst: str, sources: list[str], responsive: list[str]) -> None:
    compile_group(typst, sources)
    source = responsive[0]
    for paper in ("16-9", "4-3"):
        for appearance in ("light", "dark"):
            output = TMP / f"mosaic-layouts-title-responsive-{appearance}-{paper}.pdf"
            typst_compile(typst, source, output, "--input", f"paper={paper}", "--input", f"appearance={appearance}")
            result = command(
                [typst, "eval", "--root", ".", "--input", f"paper={paper}", "--input", f"appearance={appearance}", "query(<mosaic-overflow-warning>).len()", "--in", f"tests/{source}"],
                capture=True,
            )
            if result.stdout.strip() != "0":
                raise TestFailure(f"responsive title emitted overflow warnings for {appearance}/{paper}")

    # The title layout's field contract: every variant page of the coverage
    # fixture must carry every deck and author field. Text is compared with
    # whitespace stripped and case folded, because variants may track, wrap, or
    # uppercase a tier without dropping it.
    coverage_fields = (
        "Provable coverage", "Every field on every variant", "Ada Lovelace",
        "Charles Babbage", "Analytical Society", "University of London",
        "ada@example.org", "babbage@example.org", "2026-08-05",
    )
    coverage_pages = (
        "centered", "bordered", "ruled", "kicker", "panel",
        "academic", "image left", "inverted ruled",
    )
    for page, variant in enumerate(coverage_pages, 1):
        page_text = pdf_page_text("layouts-title-coverage", page)
        haystack = "".join(page_text.read_text(encoding="utf-8").split()).casefold()
        for expected in coverage_fields:
            needle = "".join(expected.split()).casefold()
            if needle not in haystack:
                raise TestFailure(
                    f"title coverage: {variant} (page {page}) is missing {expected!r}"
                )

    # The inverted coverage page paints the deck text color as its ground and
    # knocks the type out in the canvas color.
    typst_compile(typst, "layouts-title-coverage.typ", TMP / "mosaic-layouts-title-coverage-{p}.svg", "--format", "svg")
    inverted = TMP / "mosaic-layouts-title-coverage-8.svg"
    require_contains(inverted, "#18181b")
    require_contains(inverted, "#f8f8f7")

    typst_compile(typst, "layout-accents.typ", TMP / "mosaic-layout-accents-{0p}.svg", "--format", "svg")
    for page, color in enumerate(("#654321", "#a1b2c3"), 1):
        require_contains(TMP / f"mosaic-layout-accents-{page}.svg", color)

    furniture = pdf_text("setup-foreground-furniture")
    for expected in ("Mosaic furniture test", "1/3", "2/3", "No furniture"):
        require_contains(furniture, expected)
    require_contains(furniture, "3/3", count=0)

    for source, output in (
        ("layouts-label-style.typ", "mosaic-layouts-label-style-{p}.svg"),
        ("layouts-setup-settings.typ", "mosaic-setup-settings-{p}.svg"),
        ("layouts-progress.typ", "mosaic-layouts-progress-{p}.svg"),
    ):
        typst_compile(typst, source, TMP / output)
    for color in ("#123456", "#fedcba", "#77aa11"):
        require_contains(TMP / "mosaic-layouts-label-style-1.svg", color)
    for color in ("#123456", "#abcdef"):
        require_contains(TMP / "mosaic-setup-settings-1.svg", color)

    # One rule on the title or section cell recolors every tier composed inside
    # it, so no muted default survives on the overridden pages.
    typst_compile(typst, "layouts-stack-fill.typ", TMP / "mosaic-layouts-stack-fill-{p}.svg", "--format", "svg")
    stack_default = TMP / "mosaic-layouts-stack-fill-1.svg"
    for color in ("#18181b", "#737373"):
        require_contains(stack_default, color)
    for page, color in ((2, "#fedcba"), (3, "#abcdef")):
        path = TMP / f"mosaic-layouts-stack-fill-{page}.svg"
        require_contains(path, color)
        require_contains(path, "#737373", absent=True)
    for page, color in enumerate(("#d97706", "#ffffff", "#fedcba", "#123456"), 1):
        require_contains(TMP / f"mosaic-layouts-progress-{page}.svg", color)

def negative_expectations() -> dict[str, str]:
    expectations: dict[str, str] = {}
    path = TESTS / "invalid/expected-diagnostics.txt"
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line:
            continue
        stem, expected = line.split("|", 1)
        if stem in expectations:
            raise TestFailure(f"duplicate diagnostic manifest entry: {stem}")
        expectations[stem] = expected
    fixtures = {path.stem for path in (TESTS / "invalid").glob("*.typ")}
    if set(expectations) != fixtures:
        raise TestFailure(
            f"negative manifest mismatch: missing={sorted(fixtures - set(expectations))}, stale={sorted(set(expectations) - fixtures)}"
        )
    return expectations


def run_negative(typst: str) -> None:
    for stem, expected in sorted(negative_expectations().items()):
        source = f"tests/invalid/{stem}.typ"
        output = TMP / f"mosaic-invalid-{stem}.pdf"
        print(f"{typst} compile (expect failure) {source}", flush=True)
        result = subprocess.run(
            [typst, "compile", "--root", ".", source, str(output)],
            cwd=ROOT,
            text=True,
            capture_output=True,
        )
        log = result.stdout + result.stderr
        (TMP / f"mosaic-invalid-{stem}.log").write_text(log, encoding="utf-8")
        if result.returncode == 0:
            raise TestFailure(f"expected {source} to fail")
        native = expected.startswith("native:")
        expected = expected.removeprefix("native:")
        if not native and "mosaic:" not in log:
            raise TestFailure(f"{source} did not emit a Mosaic diagnostic")
        if expected not in log:
            raise TestFailure(f"{source} did not emit expected diagnostic: {expected}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("group", choices=("core", "layout", "negative", "all"))
    parser.add_argument("--typst", default=os.environ.get("TYPST", "typst"))
    args = parser.parse_args()
    if shutil.which(args.typst) is None:
        raise TestFailure(f"Typst executable not found: {args.typst}")
    data = manifest()
    if args.group in ("core", "all"):
        run_core(args.typst, data["core"])
    if args.group in ("layout", "all"):
        run_layout(args.typst, data["layout"], data["responsive"])
    if args.group in ("negative", "all"):
        run_negative(args.typst)
    print(f"Mosaic {args.group} tests: PASS")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except TestFailure as error:
        print(f"test failure: {error}", file=sys.stderr)
        raise SystemExit(1)

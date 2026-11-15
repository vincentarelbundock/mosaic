#!/usr/bin/env python3
"""Run Mosaic's explicit positive and negative test manifests."""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TESTS = ROOT / "tests"
# A directory of this run's own. Assertions read outputs back by fixed names
# (`mosaic-<stem>-<page>.svg`), so in a shared directory a page the fixture no
# longer produces would still be found, left there by an earlier run, and the
# assertion would pass on it. Removed after a passing run, kept after a failure.
TMP = Path(tempfile.mkdtemp(prefix="mosaic-tests-"))


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


def pdf_word_boxes(stem: str, page: int) -> dict[str, tuple[float, float]]:
    """The vertical extent (top, bottom) of each word on one page, keyed by the
    word. Later duplicates overwrite earlier ones, so fixtures that read a
    position mark it with a token that occurs once."""
    source = TMP / f"mosaic-{stem}.pdf"
    target = TMP / f"mosaic-{stem}-page-{page}-bbox.html"
    command([
        "pdftotext", "-bbox", "-f", str(page), "-l", str(page),
        str(source), str(target),
    ])
    boxes: dict[str, tuple[float, float]] = {}
    pattern = re.compile(
        r'<word xMin="[^"]*" yMin="([^"]*)" xMax="[^"]*" yMax="([^"]*)">([^<]*)</word>'
    )
    for top, bottom, word in pattern.findall(target.read_text(encoding="utf-8")):
        boxes[word] = (float(top), float(bottom))
    return boxes


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


def pdf_tags(path: Path) -> dict[str, object]:
    """What the tagged-PDF export says about a deck, read from the bytes.

    Structure elements are plain objects, so `/S/H1` counts directly, in the
    style of the suite's other output greps. Marked-content operators live in
    the Flate content streams, which stdlib `zlib` inflates, so the suite
    needs no new prerequisite to tell a tagged span from an artifact. Typst
    writes one content stream per page in page order, so `pages` indexes by
    page: each entry counts the `/Span` and `/Artifact` marked-content
    sequences opened on that page.
    """
    data = path.read_bytes()
    pages: list[tuple[int, int]] = []
    for match in re.finditer(rb"stream\r?\n(.*?)\r?\nendstream", data, re.S):
        try:
            inflated = zlib.decompress(match.group(1))
        except zlib.error:
            continue
        ops = re.findall(rb"/(Span|Artifact)\s*(?:<<|BMC|BDC)", inflated)
        if ops:
            pages.append((ops.count(b"Span"), ops.count(b"Artifact")))
    return {
        "h1": len(re.findall(rb"/S\s*/H1\b", data)),
        "h2": len(re.findall(rb"/S\s*/H2\b", data)),
        "ua": b"pdfuaid:part" in data and b"/DisplayDocTitle true" in data,
        "pages": pages,
    }


def run_core(typst: str, sources: list[str]) -> None:
    compile_group(typst, sources)

    # The exporter contract, guarded rather than owned: a default export is
    # tagged but carries no PDF/UA identification, a ua-1 export carries it.
    # Then Mosaic's part: the title slide is the H1, no theme's chrome is
    # announced, and mono's prompt stays out of its heading.
    plain = pdf_tags(TMP / "mosaic-accessibility.pdf")
    if plain["ua"]:
        raise TestFailure("a default export must not claim PDF/UA conformance")
    for theme in ("default", "editorial", "metropolis", "manifesto", "mono"):
        output = TMP / f"mosaic-accessibility-{theme}.pdf"
        typst_compile(typst, "accessibility.typ", output, "--pdf-standard", "ua-1", "--input", f"theme={theme}")
        tags = pdf_tags(output)
        if not tags["ua"]:
            raise TestFailure(f"{output} lacks the PDF/UA identification")
        if tags["h1"] != 1 or tags["h2"] != 2:
            raise TestFailure(f"{output} tags {tags['h1']} H1 and {tags['h2']} H2 elements, expected 1 and 2")
        if len(tags["pages"]) != 3:
            raise TestFailure(f"{output} has {len(tags['pages'])} tagged pages, expected 3")
        spans, _ = tags["pages"][1]
        if spans != 1:
            raise TestFailure(f"{output} page 2 tags {spans} spans, expected the heading alone")

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

    # components.progress() quiets itself where its counter has no meaningful
    # reading: the slides count on unnumbered pages, the sections count before
    # the first section slide. quiet: false always displays, and quiet: true
    # silences every unnumbered page even for the sections count.
    quiet_title = pdf_page_text("progress-quiet", 1)
    require_contains(quiet_title, "ALW0/2")
    for marker in ("SEC1", "NUM0", "ALL1"):
        require_contains(quiet_title, marker, absent=True)
    quiet_section = pdf_page_text("progress-quiet", 2)
    require_contains(quiet_section, "SEC1/1")
    require_contains(quiet_section, "ALW0/2")
    for marker in ("NUM0", "NUM1", "ALL1"):
        require_contains(quiet_section, marker, absent=True)
    quiet_content = pdf_page_text("progress-quiet", 3)
    for marker in ("SEC1/1", "NUM1/2", "ALW1/2", "ALL1/1"):
        require_contains(quiet_content, marker)

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
    # `idx` counts physical pages from zero, as pdfpc's own files do, so the
    # notes on pages 1, 4, and 5 are keyed 0, 3, and 4.
    notes = {page["idx"]: page["note"] for page in embedded["pages"]}
    if sorted(notes) != [0, 3, 4]:
        raise TestFailure(f"embedded pdfpc pages: {sorted(notes)}")
    if notes[0] != "EMBED FIRST NOTE":
        raise TestFailure(f"embedded note on page 1: {notes[0]!r}")
    # The frame's own note, on the frame rather than on the slide's first page.
    if notes[3] != "EMBED FRAME NOTE":
        raise TestFailure(f"embedded note on page 4: {notes[3]!r}")
    if notes[4] != "EMBED PAIR ONE\n\nEMBED PAIR TWO":
        raise TestFailure(f"embedded notes on page 5: {notes[4]!r}")

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

    # A leading pause (the very first token in the slide) and pauses adjacent
    # on one line, with no intervening whitespace node, must fold exactly like
    # the line-separated markers above: one page per slide, not one extra
    # blank frame per empty segment.
    empty_markers_inline = pdf_text("pause-empty-markers-inline")
    require_contains(empty_markers_inline, "LEAD")
    require_contains(empty_markers_inline, "ADJ")
    require_contains(pdf_info("pause-empty-markers-inline"), "Pages:           2")

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

    # An inverted slide's ground covers the whole page, not just the content
    # area inside a reclaimed page margin: one page-sized rectangle in the
    # inverted canvas color, beside the frame's own smaller one.
    typst_compile(typst, "slide-invert-margin.typ", TMP / "mosaic-slide-invert-margin-{p}.svg", "--format", "svg")
    require_contains(
        TMP / "mosaic-slide-invert-margin-1.svg",
        '<path fill="#18181b" fill-rule="nonzero" d="M 0 0v 135h 240v -135Z "',
        count=1,
    )

    # A cell hidden by `steps.on` hides its whole surface: the fills label
    # rules paint on three such cells are absent from frame 1 and all present
    # on frame 2.
    typst_compile(typst, "incremental-cell-surface.typ", TMP / "mosaic-incremental-cell-surface-{p}.svg", "--format", "svg")
    for color in ("#ff4136", "#0074d9", "#2ecc40"):
        require_contains(TMP / "mosaic-incremental-cell-surface-1.svg", color, absent=True)
        require_contains(TMP / "mosaic-incremental-cell-surface-2.svg", color)

    section = pdf_text("section-counter")
    require_contains(section, "1/2")
    require_contains(section, "2/2")

    # Fixtures that were compile-only, each given the one output fact its name
    # promises. A lone slide is one page, with no leading blank.
    require_contains(pdf_info("single"), "Pages:           1")
    # A two-column content layout sets the automatic heading beside the body,
    # so the header cell and the body cell share a baseline.
    require_same_line(pdf_text("headings-content-layout"), "Heading in the", "Body in the")
    require_same_line(pdf_text("headings-multi-cell"), "Automatic", "The automatic slide")
    # A deck's own show rule written after setup wins: the heading takes the
    # later green, not the earlier red, and the caption keeps its blue.
    typst_compile(typst, "setup-native-styles.typ", TMP / "mosaic-setup-native-styles-{p}.svg", "--format", "svg")
    native_styles = TMP / "mosaic-setup-native-styles-1.svg"
    require_contains(native_styles, "#2ecc40")
    require_contains(native_styles, "#0074d9")
    require_contains(native_styles, "#ff4136", absent=True)
    # Themes that widen tight lists keep every spelling of an enum and every
    # argument a list was written with. The fixture asserts the spacing
    # itself; the numbering is only visible in the rendered text.
    for theme in ("editorial", "metropolis", "manifesto", "mono"):
        output = TMP / f"mosaic-theme-lists-{theme}.pdf"
        typst_compile(typst, "theme-lists.typ", output, "--input", f"theme={theme}")
        lists = TMP / f"mosaic-theme-lists-{theme}.txt"
        command(["pdftotext", "-layout", "-f", "1", "-l", "1", str(output), str(lists)])
        for expected in (
            "1. PLUS ONE", "2. PLUS TWO", "7. SEVEN", "8. EIGHT",
            "3. THREE", "4. FOUR", "a) ALPHA", "b) BETA", "ZZ MARKED",
        ):
            require_contains(lists, expected)

    # An inverted slide takes the syntax highlighting theme of its own canvas:
    # the dark theme's keyword red on the inverted slide of a light deck, the
    # light theme's on the inverted slide of a dark one (Mono), and never the
    # other polarity's.
    light_keyword, dark_keyword = "#d73948", "#ff7b72"
    for theme, plain, inverted in (
        ("default", light_keyword, dark_keyword),
        ("mono", dark_keyword, light_keyword),
    ):
        typst_compile(
            typst, "slide-invert-raw.typ",
            TMP / f"mosaic-slide-invert-raw-{theme}-{{p}}.svg",
            "--format", "svg", "--input", f"theme={theme}",
        )
        plain_page = TMP / f"mosaic-slide-invert-raw-{theme}-1.svg"
        inverted_page = TMP / f"mosaic-slide-invert-raw-{theme}-2.svg"
        require_contains(plain_page, plain)
        require_contains(plain_page, inverted, absent=True)
        require_contains(inverted_page, inverted)
        require_contains(inverted_page, plain, absent=True)
    # Mono's code panel follows the inverted palette instead of keeping the
    # deck's dark surface under the knocked-out ink.
    require_contains(TMP / "mosaic-slide-invert-raw-mono-1.svg", "#121821")
    require_contains(TMP / "mosaic-slide-invert-raw-mono-2.svg", "#121821", absent=True)

    # A deck's own `set raw(theme: ..)` survives inversion: its keyword color
    # is on both pages and neither of Mosaic's two themes replaces it.
    typst_compile(typst, "slide-invert-raw-own.typ", TMP / "mosaic-slide-invert-raw-own-{p}.svg", "--format", "svg")
    for page in (1, 2):
        own_page = TMP / f"mosaic-slide-invert-raw-own-{page}.svg"
        require_contains(own_page, "#12ab34")
        require_contains(own_page, light_keyword, absent=True)
        require_contains(own_page, dark_keyword, absent=True)

    # A neutral callout's title is set in the text color, not the line color;
    # a quotation shows its role or accent as a rail and is bare otherwise.
    typst_compile(typst, "components-roles.typ", TMP / "mosaic-components-roles-{p}.svg", "--format", "svg")
    roles = [TMP / f"mosaic-components-roles-{page}.svg" for page in (1, 2, 3, 4, 5)]
    line, accent, custom = "#abcdef", "#123456", "#fedcba"
    require_contains(roles[0], line, absent=True)
    require_contains(roles[1], custom)
    for paint in (line, accent, custom):
        require_contains(roles[2], paint, absent=True)
    require_contains(roles[3], accent)
    require_contains(roles[4], custom)

    # Under a heading offset every theme still styles the heading that opens
    # a slide; the fixture asserts that, once per theme. Section and slide
    # heading sizes are also the same with and without the offset: a theme
    # states them as multiples of the base size, which Typst's native
    # per-level heading scale does not multiply.
    for theme in ("default", "editorial", "metropolis", "manifesto", "mono"):
        sizes = {}
        for offset in ("0", "1"):
            inputs = ["--input", f"theme={theme}", "--input", f"offset={offset}"]
            typst_compile(
                typst, "heading-offset-themes.typ",
                TMP / f"mosaic-heading-offset-themes-{theme}-{offset}.pdf",
                *inputs,
            )
            sizes[offset] = [
                command(
                    [
                        typst, "query", "--root", ".", *inputs, "--field", "value", "--one",
                        "tests/heading-offset-themes.typ", f"<{probe}>",
                    ],
                    capture=True,
                ).stdout.strip()
                for probe in ("section-size", "slide-size")
            ]
        if not all(sizes["0"]) or sizes["0"] != sizes["1"]:
            raise TestFailure(f"{theme} heading sizes change under a heading offset: {sizes}")

    # `font` and `base-size` are setup options under every theme: a custom
    # theme that states nothing, the same theme with a deck's values, and a
    # bundled theme with a deck's values. The fixture asserts each case.
    for case in ("bare", "deck", "bundled"):
        typst_compile(
            typst, "theme-typography.typ",
            TMP / f"mosaic-theme-typography-{case}.pdf",
            "--input", f"case={case}",
        )

    # A theme's transforming heading rule is drawn on every frame: the title's
    # words and their bounding boxes are the same on frames 1 and 2. The body
    # differs between the frames by design, so only the lines up to the body
    # marker word are compared. Repeated under a heading offset, where the
    # slide heading is depth 2 but native level 3.
    for theme in ("default", "editorial", "metropolis", "manifesto", "mono"):
        for offset in ("0", "1"):
            output = TMP / f"mosaic-heading-decoration-{theme}-{offset}.pdf"
            typst_compile(
                typst, "heading-decoration-themes.typ", output,
                "--input", f"theme={theme}", "--input", f"offset={offset}",
            )
            titles = []
            for page in (1, 2):
                boxes = command(
                    ["pdftotext", "-bbox", "-f", str(page), "-l", str(page), str(output), "-"],
                    capture=True,
                ).stdout
                words = [line.strip() for line in boxes.splitlines() if "<word" in line]
                body = next(index for index, line in enumerate(words) if "FRAMEBODY" in line)
                titles.append(words[:body])
            if not titles[0] or titles[0] != titles[1]:
                raise TestFailure(
                    f"{theme} heading differs between frames at offset {offset}: {titles}"
                )

    # Punctuation in a name no longer drops the PDF author field.
    require_contains(pdf_info("author-plain-name"), "Conan O'Brien, Ada Lovelace")


    # Steps inside native containers reach the page they name and no earlier
    # one. Each pair is the page before and after the step, and every word is
    # one token so a narrow shape cannot hyphenate it out of the grep.
    container_words = {
        2: ("TABLEFIRST", ("TABLEHEADSECOND", "TABLESECOND")),
        4: ("TERMFIRST", ("TERMSECOND",)),
        6: ("RECTFIRST", ("RECTSECOND", "CIRCLESECOND")),
        8: ("ROTATEFIRST", ("ROTATESECOND", "SCALESECOND", "MOVESECOND")),
        10: ("COLUMNFIRST", ("COLUMNSECOND", "PARSECOND")),
        12: ("MATHFIRST", ("FRACSECOND", "ROOTSECOND", "ATTACHSECOND")),
        14: ("CAPTIONFIRST", ("CAPTIONSECOND",)),
        16: ("HEADINGFIRST", ("HEADINGSECOND",)),
    }
    for expected in ("PLACEHOST", "PLACEDEFAULT", "PLACEOFFSET"):
        require_contains(pdf_page_text("incremental-containers", 1), expected)
    for page, (first, later) in container_words.items():
        before = pdf_page_text("incremental-containers", page)
        after = pdf_page_text("incremental-containers", page + 1)
        require_contains(before, first)
        for word in later:
            require_contains(before, word, absent=True)
            require_contains(after, word)
    require_contains(pdf_page_text("incremental-containers", 17), "HEADINGFIRST", absent=True)

    # A hidden list item hides its marker, and a timed list is drawn with the
    # deck's own marker and numbering. The markers are counted per page: a
    # leaked marker is in the text layer even when its item is not.
    marker_counts = {
        1: {"§": 1, "¶": 0},
        2: {"§": 2, "¶": 1},
        3: {"§": 3, "¶": 1},
        4: {"a)": 1, "b)": 0, "c)": 1},
        5: {"a)": 1, "b)": 1, "c)": 1},
        6: {"a)": 1, "b)": 0},
        7: {"a)": 1, "b)": 1},
        8: {"§": 2},
    }
    for page, counts in marker_counts.items():
        marker_page = pdf_page_text("pause-list-markers", page)
        for marker, count in counts.items():
            require_contains(marker_page, marker, count=count)

    # The embedded note text keeps the words of styled runs, symbols, escapes,
    # term lists, and math.
    flattened = json.loads(
        pdf_attachment("speaker-notes-embed-text", "speaker-notes.pdfpc")
    )["pages"]
    expected_note = (
        "Say THIS and that, cost $5 \u2013 maybe\u2026 50%. SCOPED\n\n"
        "- Term: description\n- bullet\n\nx2y"
    )
    if [page["idx"] for page in flattened] != [0]:
        raise TestFailure(f"flattened note pages: {flattened!r}")
    if flattened[0]["note"] != expected_note:
        raise TestFailure(f"flattened note text: {flattened[0]['note']!r}")

    # A timed list is the native list. The fixture's first page is a list
    # written plainly and the pages after it are the frames of its timed twin.
    # The last frame must match the plain page word for word and box for box,
    # and every earlier frame must draw what it shows where the last one does,
    # so nothing moves as the items arrive. A hidden item's marker is hidden
    # with it, so the number of words on a frame grows with the steps.
    def word_boxes(pdf: Path, page: int) -> list[str]:
        boxes = command(
            ["pdftotext", "-bbox", "-f", str(page), "-l", str(page), str(pdf), "-"],
            capture=True,
        ).stdout
        # The zero-width space is the baseline strut of a hidden-capable
        # marker; it carries no ink and no width.
        return [
            line.strip().replace("\u200b", "")
            for line in boxes.splitlines()
            if "<word" in line
        ]

    for theme in ("default", "editorial", "metropolis", "manifesto", "mono"):
        twin = TMP / f"mosaic-list-timed-twin-{theme}.pdf"
        typst_compile(typst, "list-timed-twin.typ", twin, "--input", f"theme={theme}")
        plain = word_boxes(twin, 1)
        frames = [word_boxes(twin, page) for page in range(2, 7)]
        if not plain or frames[-1] != plain:
            moved = sorted(set(plain) ^ set(frames[-1]))
            raise TestFailure(f"{theme}: a timed list differs from the plain list: {moved}")
        final = set(plain)
        for number, frame in enumerate(frames[:-1], start=1):
            stray = [word for word in frame if word not in final]
            if stray:
                raise TestFailure(f"{theme}: frame {number} of the timed list moves {stray}")
        counts = [len(frame) for frame in frames]
        if counts != sorted(counts) or counts[0] >= counts[-1]:
            raise TestFailure(f"{theme}: timed list frames do not accumulate: {counts}")

    # A component is transparent to steps: each word reaches the page its step
    # names and no earlier one. Keyed by page: words present, words absent.
    def require_words(stem: str, pages: dict[int, tuple[tuple[str, ...], tuple[str, ...]]]) -> None:
        for page, (present, absent) in pages.items():
            text = pdf_page_text(stem, page)
            for word in present:
                require_contains(text, word)
            for word in absent:
                require_contains(text, word, absent=True)

    require_words("components-transparent", {
        1: (("CARDFIRST",), ("CARDSECOND", "NESTEDFIRST", "NESTEDLATER")),
        2: (("CARDSECOND", "NESTEDFIRST"), ("NESTEDLATER",)),
        3: (("CARDFIRST", "NESTEDLATER"), ()),
        4: (("TITLEFIRST", "REVEALONE"), ("TITLESECOND", "REVEALTWO")),
        5: (("TITLESECOND", "REVEALTWO"), ("REVEALTHREE",)),
        6: (("REVEALTHREE",), ("TITLESECOND",)),
        7: (
            ("QUOTEFIRST", "QUOTEWHO", "BADGEFIRST", "DIVIDERFIRST"),
            ("QUOTESECOND", "BADGESECOND", "DIVIDERSECOND"),
        ),
        8: (("QUOTESECOND", "BADGESECOND", "DIVIDERSECOND"), ()),
        9: (("FIGUREFIRST", "CAPTIONFIRST"), ("FIGURESECOND", "CAPTIONSECOND")),
        10: (("FIGURESECOND", "CAPTIONSECOND"), ()),
    })
    # The same holds for a layout's content fields: a section tagline and the
    # title layout's title and subtitle.
    require_words("layout-fields-steps", {
        1: (("TAGLINEFIRST",), ("TAGLINESECOND",)),
        2: (("TAGLINEFIRST", "TAGLINESECOND"), ()),
        3: (("FIELDTITLE", "FIELDSUBTITLE"), ("TITLESECOND", "SUBTITLESECOND")),
        4: (("TITLESECOND", "SUBTITLESECOND"), ()),
    })
    require_words("drawing-hide-optional", {
        1: (("DRAWBASE",), ("DRAWLATER",)),
        2: (("DRAWBASE", "DRAWLATER"), ()),
    })
    # Outside a deck nothing walks a component, and it draws itself.
    standalone = pdf_text("components-standalone")
    for word in (
        "STANDALONECARD", "STANDALONETITLE", "STANDALONECALLOUT",
        "STANDALONEQUOTE", "STANDALONEWHO", "STANDALONEBADGE",
    ):
        require_contains(standalone, word)
    require_contains(standalone, "Nowhere to go", absent=True)
    # The native quote's own arguments: marks on request and on an inline
    # quotation, none on the default panel.
    quoted = pdf_text("components-quote-native")
    require_contains(quoted, "\u201cMARKEDQUOTE\u201d")
    require_contains(quoted, "\u201cINLINEQUOTE\u201d")
    require_contains(quoted, "\u201cPANELQUOTE", absent=True)
    require_contains(quoted, "PANELWHO, PANELSOURCE")

    # A dimmed component mutes its own paint. The fixture's loud fills and
    # accents are nowhere on a page where a step dims the component (pages 1
    # and 5), nested component included, and present where it is lit (pages 2
    # and 4). Page 3 is a card inside hand-written gray text, which is not a
    # dimmed step: its paint is untouched.
    typst_compile(typst, "components-dimmed.typ", TMP / "mosaic-components-dimmed-{p}.svg", "--format", "svg")
    dimmed_pages = {1: False, 2: True, 3: True, 4: True, 5: False}
    for page, lit in dimmed_pages.items():
        svg = TMP / f"mosaic-components-dimmed-{page}.svg"
        for paint in ("#00ff11", "#ff0011"):
            require_contains(svg, paint, absent=not lit)
    for paint in ("#1100ff", "#ff00ee"):
        require_contains(TMP / "mosaic-components-dimmed-1.svg", paint, absent=True)
        require_contains(TMP / "mosaic-components-dimmed-2.svg", paint)

def run_layout(typst: str, sources: list[str], responsive: list[str]) -> None:
    compile_group(typst, sources)
    for source in responsive:
        stem = Path(source).stem
        for paper in ("16-9", "4-3"):
            for appearance in ("light", "dark"):
                output = TMP / f"mosaic-{stem}-{appearance}-{paper}.pdf"
                typst_compile(typst, source, output, "--input", f"paper={paper}", "--input", f"appearance={appearance}")
                result = command(
                    [typst, "eval", "--root", ".", "--input", f"paper={paper}", "--input", f"appearance={appearance}", "query(<mosaic-overflow-warning>).len()", "--in", f"tests/{source}"],
                    capture=True,
                )
                if result.stdout.strip() != "0":
                    raise TestFailure(f"{stem} emitted overflow warnings for {appearance}/{paper}")

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

    # Fixtures that were compile-only. Layout fields named on `slide` overlay
    # the configured layout rather than replace it: the title and section
    # slides change variant or number and still draw the configured accent,
    # and `columns: 2` splits the configured content body.
    typst_compile(typst, "slide-layout-fields.typ", TMP / "mosaic-slide-layout-fields-{p}.svg", "--format", "svg")
    for page in (1, 2):
        require_contains(TMP / f"mosaic-slide-layout-fields-{page}.svg", "#654321")
    require_contains(pdf_info("slide-layout-fields"), "Pages:           3")
    require_same_line(pdf_page_text("slide-layout-fields", 3), "Left column", "Right column")
    # Positional and named layout selection give the same slides.
    require_contains(pdf_info("slide-layout-positional"), "Pages:           3")
    require_contains(pdf_page_text("slide-layout-positional", 2), "Named selection of the same layout.")
    require_same_line(pdf_page_text("slide-layout-positional", 3), "Left half", "Right half")
    # One page per structural variant, and the academic title numbers a
    # repeated affiliation once.
    require_contains(pdf_info("layouts-structural"), "Pages:           12")
    require_contains(pdf_page_text("layouts-structural", 1), "1 Institute A · 2 Institute B · 3 Institute C")
    # A long title over a long author list scales down instead of overprinting
    # the byline: on every page that sets the byline beneath the heading, the
    # last title word ends above the first author.
    for page, variant in enumerate(("centered", "bordered", "ruled", "kicker", "academic"), 1):
        boxes = pdf_word_boxes("layouts-title-fit", page)
        for token in ("ZQLAST", "ZQAUTHOR"):
            if token not in boxes:
                raise TestFailure(f"title fit: {variant} (page {page}) is missing {token}")
        if boxes["ZQLAST"][1] > boxes["ZQAUTHOR"][0] + 0.5:
            raise TestFailure(
                f"title fit: {variant} (page {page}) prints its title over the byline"
            )
    typst_compile(typst, "layouts-title-fit.typ", TMP / "mosaic-layouts-title-fit-{p}.svg", "--format", "svg")
    require_contains(TMP / "mosaic-layouts-title-fit-7.svg", "#13579b")
    require_contains(TMP / "mosaic-layouts-title-fit-1.svg", "#13579b", absent=True)

    # The plain section subtitle is a caption: well under the title's size.
    boxes = pdf_word_boxes("layouts-section-fields", 1)
    title_height = boxes["ZQSECTION"][1] - boxes["ZQSECTION"][0]
    subtitle_height = boxes["zqsubtitle"][1] - boxes["zqsubtitle"][0]
    if subtitle_height > 0.6 * title_height:
        raise TestFailure("section fields: the plain subtitle is not subordinate to the title")
    # An explicit accent reaches the number in baseline and numeral, and a
    # recolored directional section cell paints its region.
    typst_compile(typst, "layouts-section-fields.typ", TMP / "mosaic-layouts-section-fields-{p}.svg", "--format", "svg")
    for page, color in ((2, "#a1b2c3"), (3, "#654321"), (4, "#fedcba")):
        require_contains(TMP / f"mosaic-layouts-section-fields-{page}.svg", color)

    # Positions: the title stack over a background picture follows a recolored
    # cell; suppressed fields leave the page without them; the panel rule is a
    # mark `rule: false` removes; an explicit accent replaces the semantic one
    # on the baseline hairline; and <mosaic-section-title> reaches the visible
    # title in every section variant.
    typst_compile(typst, "layouts-positions.typ", TMP / "mosaic-layouts-positions-{p}.svg", "--format", "svg")
    require_contains(TMP / "mosaic-layouts-positions-1.svg", "#fedcba")
    require_contains(pdf_page_text("layouts-positions", 1), "ZQDECK")
    suppressed = {
        2: (("ZQDECK",), ("ZQSUB", "ZQAUTHOR", "ZQDATE")),
        3: (("ZQAUTHOR",), ("ZQDECK", "ZQSUB", "ZQDATE")),
        4: (("ZQDECK", "ZQSUB", "ZQAUTHOR", "ZQDATE"), ()),
        5: (("ZQDECK", "ZQSUB", "ZQAUTHOR", "ZQDATE"), ()),
    }
    for page, (absent, present) in suppressed.items():
        text = pdf_page_text("layouts-positions", page)
        for token in absent:
            require_contains(text, token, absent=True)
        for token in present:
            require_contains(text, token)
    require_contains(TMP / "mosaic-layouts-positions-6.svg", "#13579b")
    require_contains(TMP / "mosaic-layouts-positions-7.svg", "#13579b", absent=True)
    require_contains(TMP / "mosaic-layouts-positions-8.svg", 'stroke="#a1b2c3"')
    for page in (9, 10, 11, 12):
        require_contains(TMP / f"mosaic-layouts-positions-{page}.svg", "#12ab34")

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
        # Only the `error:` lines are the diagnostic. The rest of the log is
        # source excerpts and package paths, and a path such as
        # `@local/mosaic:0.0.3/src/...` would satisfy a bare "mosaic:" search
        # for any error raised inside the package, Mosaic's or not.
        errors = [line for line in log.splitlines() if line.startswith("error:")]
        if not native and not any("mosaic: " in line for line in errors):
            raise TestFailure(f"{source} did not emit a Mosaic diagnostic")
        if not any(expected in line and (native or "mosaic: " in line) for line in errors):
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
        status = main()
    except TestFailure as error:
        print(f"test failure: {error}", file=sys.stderr)
        print(f"outputs kept in {TMP}", file=sys.stderr)
        raise SystemExit(1)
    shutil.rmtree(TMP, ignore_errors=True)
    raise SystemExit(status)

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


def run_core(typst: str, sources: list[str]) -> None:
    compile_group(typst, sources)

    typst_compile(typst, "setup-native-defaults.typ", TMP / "mosaic-setup-native-defaults-{0p}.svg", "--format", "svg")
    native = TMP / "mosaic-setup-native-defaults-1.svg"
    require_contains(native, "#fafaf9")
    require_contains(native, "#1c1917")

    typst_compile(typst, "image.typ", TMP / "mosaic-image-{0p}.svg", "--format", "svg")
    image = TMP / "mosaic-image-1.svg"
    require_contains(image, "#00000059")
    require_contains(image, "#ffffff33")

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

    reducer_text = pdf_text("speaker-notes-reducer")
    require_contains(reducer_text, "VISIBLE REDUCER FRAME")
    require_contains(reducer_text, "REDUCER SLOT", absent=True)
    require_contains(reducer_text, "REDUCER SECRET NOTE", absent=True)
    require_contains(reducer_text, "NESTED REDUCER SECRET NOTE", absent=True)
    metadata_show_text = pdf_text("speaker-notes-metadata-show")
    require_contains(metadata_show_text, "VISIBLE CONTENT")
    require_contains(metadata_show_text, "NESTED SECRET NOTE", absent=True)
    require_contains(metadata_show_text, "speaker-notes", absent=True)

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

    typst_compile(typst, "layout-accents.typ", TMP / "mosaic-layout-accents-{0p}.svg", "--format", "svg")
    for page, color in enumerate(("#123456", "#654321", "#a1b2c3", "#bc3172"), 1):
        require_contains(TMP / f"mosaic-layout-accents-{page}.svg", color)

    features = pdf_text("layouts-features")
    for expected in ("Mosaic feature test", "1/2", "2/2"):
        require_contains(features, expected)

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
    for page, color in enumerate(("#d97706", "#ffffff", "#fedcba", "#123456"), 1):
        require_contains(TMP / f"mosaic-layouts-progress-{page}.svg", color)

    logos = pdf_text("layouts-logo")
    require_contains(logos, "GLOBAL-LOGO", count=1)
    require_contains(logos, "LOCAL-LOGO", count=0)


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
        if "mosaic:" not in log:
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

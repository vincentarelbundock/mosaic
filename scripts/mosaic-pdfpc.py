#!/usr/bin/env python3
"""Write the pdfpc sidecar for a Mosaic deck.

pdfpc reads speaker notes from a JSON file named after the PDF and sitting
beside it: present `talk.pdf` and pdfpc looks for `talk.pdfpc`. Mosaic already
builds that file's exact contents while compiling the deck and publishes them as
`<mosaic-pdfpc>` metadata; this lifts them out with `typst query` and writes them
where pdfpc will look.

    scripts/mosaic-pdfpc.py talk.typ            # -> talk.pdfpc
    scripts/mosaic-pdfpc.py talk.typ -o out/talk.pdfpc

The payload is generated inside the deck, so nothing here interprets notes: the
flattening from Typst content to Markdown text lives in `mosaic/src/pdfpc.typ`,
and this stays a transport.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

QUERY = "query(<mosaic-pdfpc>).map(it => it.value)"


class Failure(Exception):
    """A condition the user has to fix, reported without a traceback."""


def query_payload(typst: str, source: Path, root: Path) -> str:
    """The pdfpc JSON the deck generated, as a string."""
    result = subprocess.run(
        [typst, "eval", QUERY, "--in", str(source), "--root", str(root)],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        raise Failure(f"typst could not compile {source}:\n{result.stderr.strip()}")
    try:
        records = json.loads(result.stdout)
    except json.JSONDecodeError as error:
        raise Failure(f"typst returned no readable metadata: {error}") from error
    if not records:
        raise Failure(
            f"{source} declares no speaker notes, so there is no sidecar to write"
        )
    return records[0]["payload"]


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("source", type=Path, help="the deck's .typ file")
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        help="where to write the sidecar (default: the source with a .pdfpc suffix)",
    )
    parser.add_argument(
        "--root",
        type=Path,
        help="the Typst compilation root (default: the source's directory)",
    )
    parser.add_argument("--typst", default="typst", help="the typst binary to run")
    args = parser.parse_args(argv)

    source = args.source
    if not source.is_file():
        print(f"mosaic-pdfpc: no such file: {source}", file=sys.stderr)
        return 1
    root = args.root or source.parent
    # Named after the PDF, not after the source, because that is the name pdfpc
    # looks for; the two agree for the usual `typst compile talk.typ` build.
    output = args.output or source.with_suffix(".pdfpc")

    try:
        payload = query_payload(args.typst, source, root)
    except Failure as failure:
        print(f"mosaic-pdfpc: {failure}", file=sys.stderr)
        return 1

    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(payload, encoding="utf-8")
    pages = len(json.loads(payload)["pages"])
    print(f"mosaic-pdfpc: wrote {output} ({pages} annotated frames)")
    return 0


if __name__ == "__main__":
    sys.exit(main())

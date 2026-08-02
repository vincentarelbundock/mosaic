#!/usr/bin/env python3
"""List examples rendered through the embedded PDF slideshow viewer."""

from __future__ import annotations

import sys
from pathlib import Path

from embedded_examples import parse_calls


def main(paths: list[str]) -> int:
    slugs = {
        call.slug
        for call in parse_calls([Path(path) for path in paths])
        if call.renderer == "slideshow"
    }
    print(*sorted(slugs), sep="\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))

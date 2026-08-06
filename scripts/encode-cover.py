#!/usr/bin/env python3
"""Encode a slideshow cover poster as WebP and drop the intermediate PNG.

Typst renders the first frame to PNG; the site only ever shows it as the poster
image of a `pdf-slideshow`, bounded to 42em, so a 2x raster is indistinguishable
from the vector export it replaces at a fraction of the size.
"""

from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image

QUALITY = 82


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: encode-cover.py <source.png> <target.webp>", file=sys.stderr)
        return 2

    source, target = Path(sys.argv[1]), Path(sys.argv[2])
    with Image.open(source) as image:
        image.convert("RGB").save(target, "WEBP", quality=QUALITY, method=6)
    source.unlink()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

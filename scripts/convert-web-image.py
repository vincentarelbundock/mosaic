#!/usr/bin/env python3
"""Create deterministic, metadata-free WebP derivatives for documentation."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageOps


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--max-width", type=int)
    parser.add_argument("--max-height", type=int)
    parser.add_argument("--quality", type=int, default=80)
    args = parser.parse_args()
    with Image.open(args.source) as original:
        transposed = ImageOps.exif_transpose(original)
        assert transposed is not None
        image = transposed.convert("RGB")
        width = args.max_width or image.width
        height = args.max_height or image.height
        image.thumbnail((width, height), Image.Resampling.LANCZOS)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        image.save(args.output, "WEBP", quality=args.quality, method=6, exif=b"")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

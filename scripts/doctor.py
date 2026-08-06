#!/usr/bin/env python3
"""Report mandatory, target-specific, and optional Mosaic build prerequisites."""

from __future__ import annotations

import argparse
import importlib.util
import shutil
import subprocess


GROUPS = {
    "check": {
        "commands": ("uv", "typst", "pdftotext", "pdfinfo"),
        "modules": (),
    },
    "docs": {
        "commands": ("calepin", "pdftoppm", "ffmpeg", "ffprobe"),
        "modules": ("PIL",),
    },
}
OPTIONAL_COMMANDS = ("kpsewhich", "Rscript")
OPTIONAL_MODULES = ("jupyter_client",)
OPTIONAL_FONTS = ("Inter", "Source Sans 3", "Fira Sans", "Fira Mono")


def available_font_names() -> str:
    typst = shutil.which("typst")
    if not typst:
        return ""
    result = subprocess.run([typst, "fonts"], text=True, capture_output=True)
    return result.stdout.casefold() if result.returncode == 0 else ""


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("target", choices=("check", "docs", "all"), nargs="?", default="all")
    args = parser.parse_args()
    selected = ("check", "docs") if args.target == "all" else (args.target,)
    missing: list[str] = []
    print("Required prerequisites:")
    for group in selected:
        for command in GROUPS[group]["commands"]:
            path = shutil.which(command)
            print(f"  [{group}] {command}: {path or 'MISSING'}")
            if not path:
                missing.append(f"{group}: command {command}")
        for module in GROUPS[group]["modules"]:
            found = importlib.util.find_spec(module) is not None
            print(f"  [{group}] Python module {module}: {'found' if found else 'MISSING'}")
            if not found:
                missing.append(f"{group}: Python module {module}")

    print("Optional prerequisites:")
    for command in OPTIONAL_COMMANDS:
        print(f"  {command}: {shutil.which(command) or 'not found'}")
    for module in OPTIONAL_MODULES:
        found = importlib.util.find_spec(module) is not None
        print(f"  Python module {module}: {'found' if found else 'not found'}")
    fonts = available_font_names()
    for font in OPTIONAL_FONTS:
        print(f"  font {font}: {'found' if font.casefold() in fonts else 'not found'}")

    if missing:
        print("Missing required prerequisites:")
        for item in missing:
            print(f"  - {item}")
        return 1
    print(f"Prerequisites: PASS ({args.target})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

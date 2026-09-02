#!/usr/bin/env python3
"""Report mandatory, target-specific, and optional Mosaic build prerequisites."""

from __future__ import annotations

import argparse
import importlib.util
import re
import shutil
import subprocess


GROUPS = {
    "check": {
        "commands": ("uv", "typst", "pdftotext", "pdfinfo", "pdfdetach", "ffprobe"),
        "modules": ("PIL",),
    },
    "docs": {
        "commands": ("calepin", "typst-doc", "pdftoppm", "ffmpeg", "ffprobe"),
        "modules": ("PIL",),
    },
}
OPTIONAL_COMMANDS = ("kpsewhich", "Rscript")
OPTIONAL_MODULES = ("jupyter_client",)
OPTIONAL_FONTS = ("Inter", "Source Sans 3", "Fira Sans", "Fira Mono")

# make artifacts (Makefile:199) uses the "&:" grouped-target syntax, which GNU
# Make only understands from 4.3 onward; stock macOS ships 3.81.
MAKE_MIN_VERSION = (4, 3)


def make_version() -> tuple[int, ...] | None:
    """Parse the version out of `make --version`'s first line, or None."""
    make = shutil.which("make")
    if not make:
        return None
    result = subprocess.run([make, "--version"], text=True, capture_output=True)
    if result.returncode != 0:
        return None
    match = re.search(r"(\d+(?:\.\d+)+)", result.stdout.splitlines()[0] if result.stdout else "")
    if not match:
        return None
    try:
        return tuple(int(part) for part in match.group(1).split("."))
    except ValueError:
        return None


def check_make_version(missing: list[str], group: str) -> None:
    version = make_version()
    if version is None:
        print(f"  [{group}] make --version: unparseable")
        missing.append(f"{group}: make --version could not be parsed")
        return
    version_str = ".".join(str(part) for part in version)
    ok = version >= MAKE_MIN_VERSION
    min_str = ".".join(str(part) for part in MAKE_MIN_VERSION)
    print(f"  [{group}] make: {version_str} ({'>= ' + min_str if ok else 'MISSING, need >= ' + min_str})")
    if not ok:
        missing.append(f"{group}: make {version_str} is older than required {min_str} (needed for the '&:' grouped-target syntax used by `make artifacts`)")


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
        if group == "docs":
            check_make_version(missing, group)

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

#!/usr/bin/env python3
"""Report mandatory, target-specific, and optional Mosaic build prerequisites."""

from __future__ import annotations

import argparse
import importlib.util
import os
import re
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# `make doctor` passes the binaries its own variables name, so an override such
# as `make TYPST=/opt/typst doctor` checks the binary the other targets will
# run. Run directly, the script falls back to the default names.
TYPST = os.environ.get("TYPST") or "typst"
CALEPIN = os.environ.get("CALEPIN") or "calepin"
TYPSTDOC = os.environ.get("TYPSTDOC") or "typst-doc"
MAKE = os.environ.get("MAKE") or "make"

GROUPS = {
    "check": {
        "commands": ("uv", "git", TYPST, "pdftotext", "pdfinfo", "pdfdetach", "ffprobe"),
        "modules": ("PIL",),
    },
    "docs": {
        # bash and sha256sum are scripts/build-docs-showcase-video.sh's; git
        # is publish-docs' and release-stage's.
        "commands": (CALEPIN, TYPSTDOC, "git", "pdftoppm", "ffmpeg", "ffprobe", "bash", "sha256sum"),
        "modules": ("PIL",),
    },
}
OPTIONAL_COMMANDS = ("kpsewhich", "Rscript")
OPTIONAL_MODULES = ("jupyter_client",)
OPTIONAL_FONTS = ("Inter", "Source Sans 3", "Fira Sans", "Fira Mono")

# make artifacts uses the "&:" grouped-target syntax, which GNU Make only
# understands from 4.3 onward; stock macOS ships 3.81.
MAKE_MIN_VERSION = (4, 3)
# scripts/build-docs-showcase-video.sh uses `mapfile` (4.0) and a negative
# array index (4.3); stock macOS ships bash 3.2.
BASH_MIN_VERSION = (4, 3)


def tool_version(command: str, *args: str) -> tuple[int, ...] | None:
    """Parse the first dotted number `command --version` prints, or None."""
    path = shutil.which(command)
    if not path:
        return None
    result = subprocess.run([path, *(args or ("--version",))], text=True, capture_output=True)
    if result.returncode != 0:
        return None
    match = re.search(r"(\d+(?:\.\d+)+)", result.stdout.splitlines()[0] if result.stdout else "")
    if not match:
        return None
    return tuple(int(part) for part in match.group(1).split("."))


def typst_min_version() -> tuple[int, ...]:
    """The compiler floor the package manifest declares."""
    manifest = (ROOT / "mosaic/typst.toml").read_text(encoding="utf-8")
    match = re.search(r'(?m)^compiler\s*=\s*"(\d+(?:\.\d+)*)"', manifest)
    return tuple(int(part) for part in match.group(1).split(".")) if match else (0,)


def check_version(
    missing: list[str], group: str, command: str, minimum: tuple[int, ...], reason: str
) -> None:
    version = tool_version(command)
    if version is None:
        # A missing binary is already reported by the command list; only an
        # unreadable version is news here.
        if shutil.which(command):
            print(f"  [{group}] {command} --version: unparseable")
            missing.append(f"{group}: {command} --version could not be parsed")
        return
    version_str = ".".join(str(part) for part in version)
    min_str = ".".join(str(part) for part in minimum)
    ok = version >= minimum
    print(f"  [{group}] {command} version: {version_str} ({'>= ' + min_str if ok else 'TOO OLD, need >= ' + min_str})")
    if not ok:
        missing.append(f"{group}: {command} {version_str} is older than required {min_str} ({reason})")


def available_font_names() -> str:
    typst = shutil.which(TYPST)
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
        if group == "check":
            check_version(missing, group, TYPST, typst_min_version(), "the compiler floor in mosaic/typst.toml")
        if group == "docs":
            check_version(missing, group, MAKE, MAKE_MIN_VERSION, "the '&:' grouped-target syntax used by `make artifacts`")
            check_version(missing, group, "bash", BASH_MIN_VERSION, "mapfile and negative array indices in scripts/build-docs-showcase-video.sh")

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

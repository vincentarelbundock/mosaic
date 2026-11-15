#!/usr/bin/env python3
"""Verify that every development-version pin names the version in typst.toml.

`mosaic/typst.toml` is the single source of the development version. Two other
spellings must move with it and nothing else ties them together:

- every `@local/mosaic:X.Y.Z` import in the repository, because `make install`
  installs only the manifest's version, so a stale pin either fails to resolve
  or, worse, resolves to a snapshot an earlier install left behind;
- the state-key namespace `tag` in `mosaic/src/shared.typ`.

The released version (`@preview/mosaic:...`) moves independently and is not
checked here.
"""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "mosaic/typst.toml"
SHARED = ROOT / "mosaic/src/shared.typ"
# Build output, the staged release, the tooling environment, and the preview
# assets: none of them is authored against the development version.
EXCLUDED = ("docs/", "dist/", ".venv/", "preview/")
PIN = re.compile(r"@local/mosaic:(\d+(?:\.\d+)*)")
TAG = re.compile(r'(?m)^#let tag = "mosaic:([^"]+)"')


def manifest_version() -> str:
    match = re.search(r'(?m)^version\s*=\s*"([^"]+)"', MANIFEST.read_text(encoding="utf-8"))
    if not match:
        raise SystemExit(f"version check: no version in {MANIFEST.relative_to(ROOT)}")
    return match.group(1)


def tracked_files() -> list[Path]:
    result = subprocess.run(
        ["git", "ls-files", "-z"], cwd=ROOT, capture_output=True, text=True
    )
    if result.returncode != 0:
        raise SystemExit(f"version check: git ls-files failed: {result.stderr.strip()}")
    return [
        ROOT / name
        for name in result.stdout.split("\0")
        if name and not name.startswith(EXCLUDED)
    ]


def main() -> int:
    version = manifest_version()
    failures: list[str] = []
    files = 0
    pins = 0
    for path in tracked_files():
        try:
            text = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, FileNotFoundError, IsADirectoryError):
            continue
        files += 1
        for number, line in enumerate(text.splitlines(), 1):
            for match in PIN.finditer(line):
                pins += 1
                if match.group(1) != version:
                    failures.append(
                        f"{path.relative_to(ROOT)}:{number}: @local/mosaic:{match.group(1)}"
                    )

    tag = TAG.search(SHARED.read_text(encoding="utf-8"))
    if tag is None:
        failures.append(f"{SHARED.relative_to(ROOT)}: no `#let tag = \"mosaic:...\"` line")
    elif tag.group(1) != version:
        failures.append(f"{SHARED.relative_to(ROOT)}: tag is mosaic:{tag.group(1)}")

    if failures:
        stale = sorted({failure.split(":", 1)[0] for failure in failures})
        print(
            f"development version is {version} (mosaic/typst.toml); "
            f"{len(failures)} stale references in {len(stale)} files:",
            file=sys.stderr,
        )
        print("\n".join(f"- {failure}" for failure in failures), file=sys.stderr)
        return 1
    print(f"Version pins: PASS ({pins} @local/mosaic:{version} references, {files} files)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

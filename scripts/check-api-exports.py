#!/usr/bin/env python3
"""Verify Mosaic's Typst facade exports from authored import declarations."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
IMPORT = re.compile(
    r'#import\s+"([^"]+)"\s*(?:(?:as\s+([A-Za-z_][\w-]*))|(?::\s*(\([^)]*\)|[^\n]+)))?',
    re.S,
)
LET = re.compile(r"(?m)^#let\s+([A-Za-z_][A-Za-z0-9_-]*)\b")

NEUTRAL_API = {"setup", "definition", "slide", "note", "pause", "fit", "surface", "grid", "layouts", "steps", "components", "theme", "themes"}
SHARED_API = {"slide", "note", "pause", "fit", "surface", "grid", "layouts", "steps", "components", "theme"}
THEMED_API = {"setup", "definition", "slide", "note", "pause", "fit", "surface", "grid", "layouts", "steps", "components", "theme"}
THEMED_LAYOUTS = {"content", "title", "section", "image", "author"}
THEMED_COMPONENTS = {"frame", "callout", "label", "quote", "divider", "progress", "image", "figure"}

EXPECTED = {
    "mosaic/lib.typ": NEUTRAL_API,
    "mosaic/src/shared-api.typ": SHARED_API,
    "mosaic/src/grid/api.typ": {"cell", "h", "v", "t"},
    "mosaic/src/surface.typ": {"surface"},
    # fit.typ is not listed: it carries the vendored fitting internals beside
    # the one public entry point, and only `fit` is re-exported from the
    # facades, which the entries above already pin.
    "mosaic/src/layout/api.typ": {"content", "title", "section", "image", "author"},
    "mosaic/src/incremental/api.typ": {"on", "reveal", "replace", "reduce"},
    "mosaic/src/component/api.typ": THEMED_COMPONENTS,
    # light-palette and light-roles are the built-in colors and semantic role
    # table, exported so a custom theme extends them instead of copying them.
    "mosaic/src/themes/extension.typ": {
        "setup",
        "normalize-lists",
        "light-palette",
        "light-roles",
    },
    "mosaic/src/themes/api.typ": {"metropolis", "cream", "minimalist", "light", "dark"},
    "mosaic/src/themes/light.typ": THEMED_API,
    "mosaic/src/themes/light/layouts.typ": THEMED_LAYOUTS,
    "mosaic/src/themes/dark.typ": THEMED_API,
    "mosaic/src/themes/metropolis.typ": THEMED_API,
    "mosaic/src/themes/cream.typ": THEMED_API,
    "mosaic/src/themes/minimalist.typ": THEMED_API,
    "mosaic/src/themes/metropolis/layouts.typ": THEMED_LAYOUTS,
    "mosaic/src/themes/cream/layouts.typ": THEMED_LAYOUTS,
    "mosaic/src/themes/minimalist/layouts.typ": THEMED_LAYOUTS,
    "mosaic/src/themes/dark/layouts.typ": THEMED_LAYOUTS,
    "mosaic/src/themes/dark/components.typ": THEMED_COMPONENTS,
}


def strip_comments(text: str) -> str:
    """Remove Typst comments while preserving strings and line structure."""
    result: list[str] = []
    index = 0
    block_depth = 0
    in_string = False
    escaped = False
    while index < len(text):
        pair = text[index:index + 2]
        char = text[index]
        if block_depth:
            if pair == "/*":
                block_depth += 1
                result.extend("  ")
                index += 2
            elif pair == "*/":
                block_depth -= 1
                result.extend("  ")
                index += 2
            else:
                result.append("\n" if char == "\n" else " ")
                index += 1
            continue
        if in_string:
            result.append(char)
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            index += 1
            continue
        if char == '"':
            in_string = True
            result.append(char)
            index += 1
        elif pair == "//":
            while index < len(text) and text[index] != "\n":
                result.append(" ")
                index += 1
        elif pair == "/*":
            block_depth = 1
            result.extend("  ")
            index += 2
        else:
            result.append(char)
            index += 1
    return "".join(result)


def resolve_import(owner: Path, raw: str) -> Path:
    return (owner.parent / raw).resolve()


def selected_names(spec: str) -> set[str]:
    spec = re.sub(r"//.*", "", spec).strip().strip("()")
    names: set[str] = set()
    for item in spec.split(","):
        parts = item.strip().split()
        if not parts or parts[0] == "*":
            continue
        name = parts[-1] if len(parts) >= 3 and parts[-2] == "as" else parts[0]
        if not name.startswith("_"):
            names.add(name)
    return names


def exports(path: Path, active: frozenset[Path] = frozenset()) -> set[str]:
    path = path.resolve()
    if path in active:
        raise RuntimeError(f"cyclic wildcard facade import involving {path}")
    text = strip_comments(path.read_text(encoding="utf-8"))
    result = {name for name in LET.findall(text) if not name.startswith("_")}
    for match in IMPORT.finditer(text):
        raw, alias, spec = match.groups()
        if raw.startswith("@"):
            if alias:
                result.add(alias)
            elif spec:
                result.update(selected_names(spec))
            continue
        target = resolve_import(path, raw)
        if alias:
            if not alias.startswith("_"):
                result.add(alias)
        elif spec and "*" in spec:
            result.update(exports(target, active | {path}))
        elif spec:
            result.update(selected_names(spec))
        else:
            result.add(target.stem)
    return result


def main() -> int:
    failures = []
    for relative, expected in EXPECTED.items():
        actual = exports(ROOT / relative)
        if actual != expected:
            failures.append(
                f"{relative}: expected {sorted(expected)!r}, got {sorted(actual)!r}"
            )
    if failures:
        print("API export contract failed:", file=sys.stderr)
        print("\n".join(f"- {failure}" for failure in failures), file=sys.stderr)
        return 1
    print(f"API export contract: PASS ({len(EXPECTED)} facades)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

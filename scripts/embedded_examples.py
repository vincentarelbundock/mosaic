"""Parse canonical embedded-example and slideshow calls from authored Typst docs."""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path

CALL_START = re.compile(r"#(?P<name>embedded-example|slideshow)\(")
SLUG = re.compile(r'^\s*calepin\.elements\.gallery\s*,\s*"(?P<slug>[^"]+)"', re.DOTALL)
FRAMES = re.compile(r"\bframes\s*:\s*(?P<frames>\d+)")
POSITIONAL_FRAMES = re.compile(
    r'^\s*calepin\.elements\.gallery\s*,\s*"[^"]+"\s*,\s*(?P<frames>\d+)',
    re.DOTALL,
)
THUMBNAIL = re.compile(r"\brenderer\s*:\s*thumbnail-gallery\b")
START = re.compile(r"\bstart\s*:\s*(?P<start>\d+)")


@dataclass(frozen=True)
class ExampleCall:
    slug: str
    frames: int
    renderer: str
    start: int
    page: Path


def call_body(source: str, open_paren: int) -> str:
    depth = 0
    in_string = False
    escaped = False
    for index in range(open_paren, len(source)):
        char = source[index]
        if in_string:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            continue
        if char == '"':
            in_string = True
        elif char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
            if depth == 0:
                return source[open_paren + 1 : index]
    raise ValueError(f"unterminated call beginning at byte {open_paren}")


def parse_calls(paths: list[Path]) -> list[ExampleCall]:
    calls: list[ExampleCall] = []
    for path in paths:
        source = path.read_text(encoding="utf-8")
        for match in CALL_START.finditer(source):
            body = call_body(source, match.end() - 1)
            slug_match = SLUG.match(body)
            if not slug_match:
                continue
            frame_match = FRAMES.search(body) or POSITIONAL_FRAMES.match(body)
            start_match = START.search(body)
            calls.append(ExampleCall(
                slug=slug_match.group("slug"),
                frames=int(frame_match.group("frames")) if frame_match else 1,
                renderer="thumbnail" if THUMBNAIL.search(body) else "slideshow",
                start=int(start_match.group("start")) if start_match else 1,
                page=path,
            ))
    return calls

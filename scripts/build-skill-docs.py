#!/usr/bin/env python3
"""Render the website sources into the Markdown reference the skill ships.

`skills/mosaic/SKILL.md` is the hand-written tutorial. Everything under
`skills/mosaic/docs/` is written by this script from `docs-src/`: one Markdown
file per website page, the API reference from typst-doc's generated entries,
and the full example decks. An agent reads SKILL.md first and opens a page only
when a task needs it, so the whole website is available without being loaded.

The converter is not a Typst parser. It knows the markup the pages actually
use: headings, emphasis, raw blocks, links, tables, and the handful of site
helpers (`embedded-example`, `unreleased`, ...). Anything it does not recognise
is reported and fails the run, so a new construct on a page is handled here
deliberately rather than leaking into the skill as Typst source.

Run through `make skill`, which generates the API entries first.
"""

from __future__ import annotations

import json
import re
import shutil
import sys
import textwrap
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DOCS_SRC = ROOT / "docs-src"
OUT = ROOT / "skills" / "mosaic" / "docs"
EMBEDDED = DOCS_SRC / "examples" / "embedded"
DECKS = DOCS_SRC / "examples" / "decks"
GENERATED = DOCS_SRC / "api" / "generated"
REPO_URL = "https://github.com/vincentarelbundock/mosaic"

API_PAGES = (
    ("setup", "Document setup"),
    ("theme", "Theme authoring"),
    ("slides", "Slides"),
    ("steps", "Incremental steps"),
    ("grids", "mosaic.grids constructors"),
    ("layouts", "Semantic layouts"),
    ("components", "Components and furniture"),
)

# Pages that are HTML chrome rather than documentation.
SKIPPED_PAGES = {"index.typ", "404.typ"}

IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_-]*(?:\.[A-Za-z_][A-Za-z0-9_-]*)*")

warnings: list[str] = []


# ------------------------------------------------------------------------------
# Scanning Typst source
# ------------------------------------------------------------------------------


def skip_raw(s: str, i: int) -> int:
    """Index just past the raw element whose opening backtick is at `i`."""
    n = 0
    while i + n < len(s) and s[i + n] == "`":
        n += 1
    if n == 2:
        return i + 2
    end = s.find("`" * n, i + n)
    if end < 0:
        return len(s)
    end += n
    while end < len(s) and s[end] == "`":
        end += 1
    return end


def skip_string(s: str, i: int) -> int:
    i += 1
    while i < len(s):
        if s[i] == "\\":
            i += 2
        elif s[i] == '"':
            return i + 1
        else:
            i += 1
    return i


def skip_code(s: str, i: int) -> int:
    """Index just past the code group, `(..)` or `{..}`, opening at `i`."""
    close = ")" if s[i] == "(" else "}"
    i += 1
    while i < len(s):
        c = s[i]
        if c == close:
            return i + 1
        if c == '"':
            i = skip_string(s, i)
        elif c == "`":
            i = skip_raw(s, i)
        elif c in "({":
            i = skip_code(s, i)
        elif c == "[":
            i = skip_markup(s, i)
        elif s.startswith("//", i):
            i = s.find("\n", i)
            i = len(s) if i < 0 else i
        else:
            i += 1
    return i


def skip_markup(s: str, i: int) -> int:
    """Index just past the content block `[..]` opening at `i`."""
    i += 1
    while i < len(s):
        c = s[i]
        if c == "]":
            return i + 1
        if c == "\\":
            i += 2
        elif c == "`":
            i = skip_raw(s, i)
        elif c == "[":
            i = skip_markup(s, i)
        elif c == "#":
            i = skip_call(s, i)
        else:
            i += 1
    return i


def skip_call(s: str, i: int) -> int:
    """Index just past a `#name(..)[..]` call at `i`, or `i + 1` if none."""
    m = IDENT.match(s, i + 1)
    if not m:
        return i + 1
    j = m.end()
    if j < len(s) and s[j] == "(":
        j = skip_code(s, j)
    while j < len(s) and s[j] == "[":
        j = skip_markup(s, j)
    return j


def split_args(inner: str) -> list[str]:
    """Split the inside of a code group at its top-level commas."""
    parts, start, i = [], 0, 0
    while i < len(inner):
        c = inner[i]
        if c == ",":
            parts.append(inner[start:i])
            start = i + 1
            i += 1
        elif c == '"':
            i = skip_string(inner, i)
        elif c == "`":
            i = skip_raw(inner, i)
        elif c in "({":
            i = skip_code(inner, i)
        elif c == "[":
            i = skip_markup(inner, i)
        elif inner.startswith("//", i):
            i = inner.find("\n", i)
            i = len(inner) if i < 0 else i
        else:
            i += 1
    parts.append(inner[start:])
    return [p.strip() for p in parts if p.strip()]


KEY = re.compile(r'^(?:([A-Za-z_][A-Za-z0-9_-]*)|"([^"]*)")\s*:(?!:)\s*', re.S)


def parse_args(inner: str) -> tuple[list[str], dict[str, str]]:
    positional, named = [], {}
    for part in split_args(inner):
        m = KEY.match(part)
        if m:
            named[m.group(1) or m.group(2)] = part[m.end():]
        else:
            positional.append(part)
    return positional, named


def unquote(src: str) -> str:
    src = src.strip()
    if len(src) >= 2 and src[0] == '"' and src[-1] == '"':
        return json.loads(src.replace("\n", "\\n"))
    return src


def content_of(src: str) -> str:
    """The markup inside a `[..]` argument; a string argument is its text."""
    src = src.strip()
    if src.startswith("[") and src.endswith("]"):
        return src[1:-1]
    return unquote(src)


def parse_value(s: str, i: int = 0):
    """Parse one Typst literal from typst-doc's data block."""
    while s[i].isspace():
        i += 1
    c = s[i]
    if c == '"':
        j = skip_string(s, i)
        return unquote(s[i:j]), j
    if c == "<":
        j = s.index(">", i) + 1
        return s[i + 1 : j - 1], j
    if c == "[":
        j = skip_markup(s, i)
        return s[i + 1 : j - 1], j
    if c == "`":
        j = skip_raw(s, i)
        body = s[i:j].strip("`")
        return body.split("\n", 1)[1].rstrip("\n") if "\n" in body else body, j
    if c == "(":
        j = skip_code(s, i)
        positional, named = [], {}
        for part in split_args(s[i + 1 : j - 1]):
            m = KEY.match(part)
            if m:
                named[m.group(1) or m.group(2)] = parse_value(part[m.end():] + " ")[0]
            else:
                positional.append(parse_value(part + " ")[0])
        return (named if named else positional), j
    m = re.compile(r"[A-Za-z0-9_.-]+").match(s, i)
    word = m.group(0)
    return {"none": None, "true": True, "false": False}.get(word, word), m.end()


# ------------------------------------------------------------------------------
# Markup to Markdown
# ------------------------------------------------------------------------------


def fenced(code: str, lang: str = "typ") -> str:
    longest = max((len(run) for run in re.findall(r"`+", code)), default=0)
    fence = "`" * max(3, longest + 1)
    return f"{fence}{lang}\n{code.rstrip()}\n{fence}"


def rewrite_url(url: str) -> str:
    if re.match(r"[a-z]+:", url) or url.startswith("#"):
        return url
    return re.sub(r"\.html(?=#|$)", ".md", url)


def blockquote(text: str) -> str:
    return "\n".join((">" + (" " + line if line else "")) for line in text.strip().split("\n"))


class Page:
    """One conversion, holding the literal fragments the text passes must skip."""

    def __init__(self, source: Path, versions: dict[str, str], unwrap: bool = False):
        self.source = source
        self.versions = versions
        self.unwrap = unwrap
        self.protected: list[str] = []

    def protect(self, literal: str, block: bool = False) -> str:
        self.protected.append(literal)
        token = f"\x00{len(self.protected) - 1}\x00"
        return f"\n\n{token}\n\n" if block else token

    def restore(self, text: str) -> str:
        pattern = re.compile(r"\x00(\d+)\x00")
        while pattern.search(text):
            text = pattern.sub(lambda m: self.protected[int(m.group(1))], text)
        return text

    def sub(self, markup: str) -> str:
        """Convert nested markup to finished Markdown."""
        child = Page(self.source, self.versions, self.unwrap)
        return child.convert(markup)

    def inline(self, markup: str) -> str:
        return re.sub(r"\s*\n\s*", " ", self.sub(markup)).strip()

    # -- site helpers ---------------------------------------------------------

    def example(self, slug: str) -> str:
        path = EMBEDDED / f"{slug}.typ"
        if not path.exists():
            warnings.append(f"{self.source}: example source {slug} not found")
            return ""
        return self.protect(fenced(path.read_text()), block=True)

    def callout(self, title: str, body: str) -> str:
        return self.protect(blockquote(f"**{title}** {body}"), block=True)

    def table(self, inner: str) -> str:
        positional, named = parse_args(inner)
        columns = named.get("columns", "1").strip()
        ncols = len(split_args(columns[1:-1])) if columns.startswith("(") else int(columns)
        header, cells = None, []
        for arg in positional:
            if arg.startswith("table.header"):
                header = [self.cell(c) for c in split_args(arg[arg.index("(") + 1 : -1])]
            elif arg.startswith("["):
                cells.append(self.cell(arg))
            else:
                warnings.append(f"{self.source}: table argument not handled: {arg[:40]}")
        rows = [cells[i : i + ncols] for i in range(0, len(cells), ncols)]
        header = header or [""] * ncols
        lines = ["| " + " | ".join(header) + " |", "|" + " --- |" * ncols]
        lines += ["| " + " | ".join(row) + " |" for row in rows]
        return self.protect("\n".join(lines), block=True)

    def cell(self, src: str) -> str:
        return self.inline(content_of(src)).replace("|", "\\|")

    def call(self, name: str, inner: str | None, bodies: list[str], raw: str) -> str:
        positional, named = parse_args(inner) if inner is not None else ([], {})
        if name == "link":
            target = positional[0]
            if target.startswith("<"):
                url = "#" + target[1:-1]
            else:
                url = rewrite_url(unquote(target))
            label = bodies[0] if bodies else (positional[1] if len(positional) > 1 else None)
            if label is None:
                return self.protect(f"<{url}>")
            return self.protect(f"[{self.inline(content_of(label))}]({url})")
        if name == "repo-file":
            url = f"{REPO_URL}/blob/main/{unquote(positional[0]).lstrip('/')}"
            return self.protect(f"[{self.inline(bodies[0][1:-1])}]({url})")
        if name == "embedded-example":
            return self.example(unquote(positional[1]))
        if name == "example-source":
            return self.example(unquote(positional[0]))
        if name == "unreleased":
            dev, released = self.versions["development"], self.versions["released"]
            what = self.inline(bodies[0][1:-1])
            return self.callout(
                f"Requires Mosaic {dev}.",
                f"{what} This is the development version, which is not on Typst Universe yet: "
                f"a deck that uses it imports `@local/mosaic:{dev}` rather than the released "
                f"`@preview/mosaic:{released}`. See [Install]({self.to_root()}start/install.md).",
            )
        if name == "calepin.elements.callout":
            title = self.inline(content_of(named["title"])) if "title" in named else "Note"
            return self.callout(f"{title}.", self.sub(textwrap.dedent(bodies[0][1:-1])))
        if name == "table":
            return self.table(inner)
        if name == "emph":
            return self.protect(f"*{self.inline(bodies[0][1:-1])}*")
        if name == "calepin.elements.columns":
            return "\n\n".join(self.sub(textwrap.dedent(content_of(arg))) for arg in positional)
        if name in {"title", "v", "html.elem"}:
            # Spacing and HTML-only figures (the SVG diagrams) have no Markdown form.
            return ""
        if name in {
            "slideshow",
            "slideshow-grid",
            "thumbnail-gallery",
            "thumbnail-gallery-items",
            "semantic-thumbnail",
            "metadata",
        }:
            # Rendered previews: the skill carries the sources, not the pictures.
            return ""
        warnings.append(f"{self.source}: unhandled call #{raw[:60]!r}")
        return self.protect(raw)

    def to_root(self) -> str:
        depth = len(self.source.relative_to(DOCS_SRC).parts) - 1 if self.source.is_relative_to(DOCS_SRC) else 1
        return "../" * depth

    # -- the conversion -------------------------------------------------------

    def statement_end(self, s: str, i: int) -> int:
        """Index past a `#import`/`#set`/`#show`/`#let` statement starting at `i`."""
        j = i
        while j < len(s) and s[j] != "\n":
            c = s[j]
            if c == '"':
                j = skip_string(s, j)
            elif c in "({":
                j = skip_code(s, j)
            elif c == "[":
                j = skip_markup(s, j)
            else:
                j += 1
        return j

    def convert(self, s: str) -> str:
        out, i = [], 0
        while i < len(s):
            c = s[i]
            line_start = i == 0 or s[i - 1] == "\n" or not s[s.rfind("\n", 0, i) + 1 : i].strip()
            if c == "`":
                j = skip_raw(s, i)
                raw = s[i:j]
                if raw.startswith("```") and "\n" in raw:
                    # The body is indented with the markup around it; the
                    # opening fence carries no indent of its own to compare.
                    first, rest = raw.split("\n", 1)
                    out.append(self.protect(first + "\n" + textwrap.dedent(rest), block=True))
                else:
                    out.append(self.protect(raw))
                i = j
            elif c == "\\" and s.startswith("\n", i + 1):
                # A forced line break.
                out.append("\n")
                i += 2
            elif c == "\\" and i + 1 < len(s):
                out.append(self.protect(s[i : i + 2]))
                i += 2
            elif s.startswith("//", i) and line_start:
                j = s.find("\n", i)
                i = len(s) if j < 0 else j + 1
            elif c == "#":
                m = IDENT.match(s, i + 1)
                if not m:
                    out.append(c)
                    i += 1
                    continue
                name = m.group(0)
                if name in {"import", "set", "show", "let"} and line_start:
                    i = self.statement_end(s, i)
                    continue
                j, inner, bodies = m.end(), None, []
                if j < len(s) and s[j] == "(":
                    k = skip_code(s, j)
                    inner = s[j + 1 : k - 1]
                    j = k
                while j < len(s) and s[j] == "[":
                    k = skip_markup(s, j)
                    bodies.append(s[j:k])
                    j = k
                if inner is None and not bodies:
                    out.append(c)
                    i += 1
                    continue
                out.append(self.call(name, inner, bodies, s[i:j]))
                # A label attached to a dropped element goes with it.
                label = re.compile(r"[ \t]*<[a-z-]+>").match(s, j)
                i = label.end() if label and name == "metadata" else j
            else:
                out.append(c)
                i += 1
        return self.restore(self.text_passes("".join(out)))

    def text_passes(self, text: str) -> str:
        # Headings: the page title is the one level-1 heading.
        text = re.sub(
            r"(?m)^(=+) +(.*?)(?: *<[a-z0-9-]+>)?[ \t]*$",
            lambda m: "#" * (len(m.group(1)) + 1) + " " + m.group(2),
            text,
        )
        text = re.sub(r"(?<![\\*\w])\*(?=\S)([^*\n]+?)(?<=\S)\*(?![*\w])", r"**\1**", text)
        text = re.sub(r"(?m)^(\s*)\+ ", r"\g<1>1. ", text)
        if self.unwrap:
            text = unwrap(text)
        text = "\n".join(line.rstrip() for line in text.split("\n"))
        return re.sub(r"\n{3,}", "\n\n", text).strip() + "\n"


STARTS_BLOCK = re.compile(r"\s*(?:[-*] |\d+\. |#|\||>|\x00\d+\x00\s*$)")


def unwrap(text: str) -> str:
    """Join hard-wrapped paragraph lines; the `///` comments wrap at a column."""
    out: list[str] = []
    for line in text.split("\n"):
        previous = out[-1] if out else ""
        joinable = (
            line.strip()
            and previous.strip()
            and not STARTS_BLOCK.match(line)
            and not re.fullmatch(r"\s*\x00\d+\x00\s*", previous)
            and not previous.lstrip().startswith(("#", "|"))
        )
        if joinable:
            out[-1] = previous.rstrip() + " " + line.strip()
        else:
            out.append(line)
    return "\n".join(out)


# ------------------------------------------------------------------------------
# Pages
# ------------------------------------------------------------------------------


def read_versions() -> dict[str, str]:
    site = (DOCS_SRC / "_includes" / "site.typ").read_text()
    return {
        "development": re.search(r'development-version = "([^"]+)"', site).group(1),
        "released": re.search(r"@preview/mosaic:([0-9.]+)", site).group(1),
    }


def page_title(source: str) -> str:
    m = re.search(r"#set document\(title: \[(.*?)\]\)", source)
    return m.group(1) if m else "Untitled"


def sidebar() -> list[tuple[str, list[str]]]:
    config = tomllib.loads((DOCS_SRC / "calepin.toml").read_text())
    return [
        (section.get("title", "Start"), [item["target"] for item in section["item"]])
        for section in config["sidebar"]["section"]
    ]


def render_page(target: str, versions: dict[str, str]) -> str:
    path = DOCS_SRC / target
    source = path.read_text()
    body = Page(path, versions).convert(source)
    return f"# {page_title(source)}\n\n{body}"


def render_examples(versions: dict[str, str]) -> str:
    decks = json.loads((DECKS / "manifest.json").read_text())["decks"]
    lines = [
        "# Examples",
        "",
        "Complete slide decks built with Mosaic. Some are built on a bundled theme, leaning on its layouts or hand-crafting every slide from named cells and custom palettes; others define a theme of their own to re-create an outside design. Each page below holds one deck's full Typst source.",
        "",
        "These are complete, fairly intricate decks: they combine custom palettes, hand-built grids, and theme extensions. Read [Get started](start/first-deck.md), [Content slides](slides/content.md), and [Themes](appearance/themes.md) first.",
        "",
    ]
    for deck in decks:
        slug = deck["slug"]
        lines.append(f"- [{deck['title']}](examples/{slug}.md): {deck['frames']} frames. [Repository]({REPO_URL}/tree/main/docs-src/examples/decks/{slug}).")
        sources = sorted(p for p in (DECKS / slug).glob("*.typ"))
        sources.sort(key=lambda p: p.name != "main.typ")
        parts = [f"# {deck['title']} example deck", "", f"A complete {deck['frames']}-frame deck. Assets, Makefile, and the compiled PDF are in the [repository]({REPO_URL}/tree/main/docs-src/examples/decks/{slug})."]
        for src in sources:
            parts += ["", f"## `{src.name}`", "", fenced(src.read_text())]
        write(f"examples/{slug}.md", "\n".join(parts) + "\n")
    return "\n".join(lines) + "\n"


def render_api_group(group: str, title: str, versions: dict[str, str]) -> tuple[str, list[str]]:
    directory = GENERATED / group
    names = json.loads((directory / "entries.json").read_text())
    dev = versions["development"]
    parts = [
        f"# {title}",
        "",
        f"Generated from the package sources, so it describes the development version ({dev}) throughout; [the changelog]({REPO_URL}/blob/main/CHANGELOG.md) lists what differs from the released one. Each entry shows the signature, a description, then the parameters with their types and defaults.",
    ]
    for name in names:
        source = (directory / f"{name}.typ").read_text()
        data = source.split("// The default typst-doc template.")[0]
        doc = {}
        for m in re.finditer(r"(?m)^#let doc-([a-z]+) = ", data):
            doc[m.group(1)] = parse_value(data, m.end())[0]
        page = Page(directory / f"{name}.typ", versions, unwrap=True)
        parts += ["", f"## {public_name(name)}", "", page.sub(doc["title"]).strip()]
        if doc.get("signature"):
            parts += ["", fenced(doc["signature"])]
        for section in doc["sections"]:
            if section["kind"] == "prose":
                parts += ["", page.sub(hanging_dedent(section["body"])).strip()]
            elif section["kind"] == "params":
                items = section["items"]
                if isinstance(items, str):
                    # The section names a data binding (`doc-params`) instead of inlining it.
                    items = doc[items.removeprefix("doc-")]
                if not items:
                    continue
                parts += ["", "**Parameters**", ""]
                for item in items:
                    label = ", ".join(f"`{n}`" for n in item["names"])
                    meta = f"`{item['type']}`" if item.get("type") else ""
                    if item.get("default") is not None:
                        default = re.sub(r"\s*\n\s*", " ", item["default"]).replace("( ", "(").replace(", )", ")")
                        meta += f", default `{default}`"
                    body = page.sub(hanging_dedent(item["body"])).strip()
                    # Lists and code blocks in the body stay blocks, nested under the bullet.
                    body = body.replace("\n", "\n  ").replace("\n  \n", "\n\n")
                    parts.append(f"- {label} ({meta}): {body}" if meta else f"- {label}: {body}")
            else:
                warnings.append(f"{directory / name}: section kind {section['kind']} not handled")
    return "\n".join(parts) + "\n", [public_name(name) for name in names]


def public_name(name: str) -> str:
    """The spelling a deck writes. The layout constructors are defined in a
    private `_base` namespace that every theme facade rebinds as `layouts`."""
    return name.replace("layouts._base.", "layouts.")


def hanging_dedent(text: str) -> str:
    """Dedent a `[..]` body whose first line starts right after the bracket."""
    first, _, rest = text.partition("\n")
    return first + ("\n" + textwrap.dedent(rest) if rest else "")


def render_api_index(entries: dict[str, list[str]]) -> str:
    lines = [
        "# API reference",
        "",
        "Every exported function, grouped by reference page. The `palettes` collection is plain data rather than a function; [Colors](appearance/colors.md#bundled-palettes) lists it. [Labels](api/labels.md) lists every label a rendered slide emits, which is the surface a deck or a theme writes `show` rules against.",
    ]
    for group, title in API_PAGES:
        names = ", ".join(f"`{name}()`" for name in entries[group])
        lines += ["", f"- [{title}](api/{group}.md): {names}"]
    return "\n".join(lines) + "\n"


written: dict[str, str] = {}


def write(relative: str, text: str) -> None:
    path = OUT / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)
    written[relative] = text


def headings(text: str) -> list[str]:
    stripped = re.sub(r"(?ms)^(`{3,}).*?^\1", "", text)
    return [m.group(1) for m in re.finditer(r"(?m)^## (.+)$", stripped)]


def main() -> int:
    versions = read_versions()
    missing = [g for g, _ in API_PAGES if not (GENERATED / g / "entries.json").exists()]
    if missing:
        print(f"build-skill-docs: no generated API entries for {missing}; run `make skill`", file=sys.stderr)
        return 1
    if OUT.exists():
        shutil.rmtree(OUT)

    api_groups = {group: title for group, title in API_PAGES}
    api_entries: dict[str, list[str]] = {}
    index = [
        "# Mosaic documentation",
        "",
        f"The Mosaic website as Markdown, generated from `docs-src/` by `scripts/build-skill-docs.py`. Do not edit these files; edit the website sources and run `make skill`. Pages describe the released version ({versions['released']}) unless a callout says a feature requires the development version ({versions['development']}); the API reference describes the development version throughout.",
        "",
        "Each entry lists the page's sections, so open only the page a task needs.",
    ]
    for section, targets in sidebar():
        index += ["", f"## {section}", ""]
        for target in targets:
            if target in SKIPPED_PAGES:
                continue
            relative = target.removesuffix(".typ") + ".md"
            stem = Path(target).stem
            if target == "examples.typ":
                text = render_examples(versions)
            elif target == "api.typ":
                for group, title in API_PAGES:
                    page, names = render_api_group(group, title, versions)
                    write(f"api/{group}.md", page)
                    api_entries[group] = names
                text = render_api_index(api_entries)
            elif target.startswith("api/") and stem in api_groups:
                text = written[relative]
            else:
                text = render_page(target, versions)
            write(relative, text)
            title = text.split("\n", 1)[0].removeprefix("# ")
            if target.startswith("api/") and stem in api_groups:
                detail = ", ".join(f"`{name}`" for name in api_entries[stem])
            else:
                detail = "; ".join(headings(text))
            index.append(f"- [{title}]({relative})" + (f": {detail}" if detail else ""))
    write("index.md", "\n".join(index) + "\n")

    for warning in warnings:
        print(f"build-skill-docs: {warning}", file=sys.stderr)
    print(f"build-skill-docs: wrote {len(written)} files to {OUT.relative_to(ROOT)}")
    return 1 if warnings else 0


if __name__ == "__main__":
    raise SystemExit(main())

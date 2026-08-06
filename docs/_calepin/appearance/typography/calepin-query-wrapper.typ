#let _calepin-document-element = document
#import "/_calepin/calepin.typ": *
#let document = _calepin-document-element



#let _raw-chunk-langs = ("python", "r", "mermaid", "dot", "tikz", "d2")
#show raw.where(block: true, lang: "typ", theme: auto): it => _without-raw-chunk-transforms(() => _html-themed-raw-block(it))
#show raw.where(block: true, lang: "typst", theme: auto): it => _without-raw-chunk-transforms(() => _html-themed-raw-block(it))
#show raw.where(block: true, lang: "python", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("python", it) }
#show raw.where(block: true, lang: "r", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("r", it) }
#show raw.where(block: true, lang: "mermaid", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("mermaid", it) }
#show raw.where(block: true, lang: "dot", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("dot", it) }
#show raw.where(block: true, lang: "tikz", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("tikz", it) }
#show raw.where(block: true, lang: "d2", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("d2", it) }

#show raw.where(block: true, theme: auto): it => {
  if _is-query() {
    it
  } else if _disable-raw-chunk-transforms.get() {
    _html-themed-raw-block(it)
  } else if it.has("lang") and it.lang != none and _raw-chunk-langs.contains(it.lang) and _fenced-chunks-runs(
    it.lang,
    _resolve-options(it.lang, _call-defaults).at("fenced-chunks"),
  ) {
    chunk_from_raw_plain(it.lang, it)
  } else {
    _html-themed-raw-block(it)
  }
}

#show heading: it => {
  if _is-html() and "label" in it.fields() {
    std.html.elem("calepin-heading-anchor", attrs: (data-id: str(it.label)))
  }
  it
}

// Notebook theme
#import "/_calepin/calepin.typ": _html-themed-raw-block, _is-query, chunk_from_raw_plain

// Body text size, captured below at document-body level. Code blocks are sized
// relative to this rather than to `1em`, which would compound: a literal
// ```typ block is rendered by replacing its source `raw` element, so it renders
// inside Typst's already-reduced raw text context, whereas executed chunks are
// emitted as ordinary calls at body size. Anchoring to the captured body size
// gives both paths a single, matching reduction instead of shrinking twice.
#let _calepin-body-size = std.state("calepin-body-size", 11pt)

#show raw.where(block: true): it => {
  if it.theme != auto {
    context {
      set text(size: _calepin-body-size.get() * 0.8)
      it
    }
  } else if it.lang != none and (_is-query() or _raw-chunk-langs.contains(it.lang)) and _fenced-chunks-runs(
    it.lang,
    _resolve-options(it.lang, _call-defaults).at("fenced-chunks"),
  ) {
    chunk_from_raw_plain(it.lang, it)
  } else {
    _html-themed-raw-block(it)
  }
}

#context _calepin-body-size.update(text.size)

#import "/_calepin/calepin.typ" as calepin
#set document(title: [Typography and color])
#metadata((title: "Typography and color")) <website-metadata>

#title()

= Typography

Place native Typst text and heading rules after `m.setup` so they apply across the deck:

```typ
#show: m.setup
#set text(font: "EB Garamond", size: 26pt)
#show heading.where(depth: 1): set text(font: "Inter", weight: "black")
#show heading.where(depth: 2): set text(size: 1.4em)
```

A semantic heading feeds outlines, bookmarks, and content slides. Use `text` directly for display type that should not appear in navigation, or exclude the heading:

```typ
#text(size: 60pt, weight: "black")[BOLD]
#heading(outlined: false, bookmarked: false)[Aside]
```

Leading, lists, and captions remain native `par`, `list`, `enum`, `terms`, and `figure.caption` styling.

A heading cannot be placed inside an incremental grid node (`m.grids.on`, `m.steps.reveal`, and related reducers); keep it structurally stable across a slide's frames.

= Color

Each theme supplies a complete color palette. Override only the deck-wide colors that need to change; omitted colors keep the theme defaults:

```typ
#show: m.setup.with(colors: (
  canvas: rgb("#f4f8f7"),
  accent: rgb("#007f73"),
))
```

The accepted roles are `canvas`, `surface`, `text`, `muted`, `line`, and `accent`. Unknown roles and non-color values are errors. The canvas, typography, components, and layouts all use the resolved values. Explicit component colors remain local overrides:

```typ
#m.slide(
  layout: m.layouts.content(variant: "header-body"),
  content: (foreground: [
    #place(bottom + left)[
      #m.components.progress(
        variant: "line",
        width: 100%,
        color: rgb("#e69f00"),
      )
    ]
  ]),
)[Title][Body]
```

Native rules after `m.setup` are still the right tool for typography or a special local composition:

```typ
#[
  #show label("mosaic-cell-body"): set text(fill: white)
  #m.slide(
    content: (background: block(width: 100%, height: 100%, fill: rgb("#111827"))),
  )[Dark for this slide only]
]
```

Color collections remain ordinary Typst arrays. Define them near the chart or diagram that uses them, or import a color package. Component `role:` values remain local to components such as `frame`, `label`, and `quote`.

To recolor an entire slide at once, use the `<mosaic-slide>` label described under #link("styling.html#styling-a-whole-slide")[Styling a whole slide].

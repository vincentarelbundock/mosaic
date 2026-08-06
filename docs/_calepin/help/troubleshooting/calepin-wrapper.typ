#let _calepin-document-element = document
#import "/_calepin/calepin.typ": *
#let document = _calepin-document-element

#let _calepin-expected-generation = "8f6e67f5f61914eb-1349cde127705c16"
#let _calepin-verify-generation() = {
  let path = sys.inputs.at("calepin-results", default: none)
  if path != none and path != "" {
    let actual = json(path).at("generation", default: "")
    if actual != _calepin-expected-generation {
      panic("Calepin results changed while this render was starting; Typst will retry with the completed build")
    }
  }
}
#_calepin-verify-generation()



#let _raw-chunk-langs = ("python", "r", "mermaid", "dot", "tikz", "d2", "sh")
#show raw.where(block: true, lang: "typ", theme: auto): it => _without-raw-chunk-transforms(() => _html-themed-raw-block(it))
#show raw.where(block: true, lang: "typst", theme: auto): it => _without-raw-chunk-transforms(() => _html-themed-raw-block(it))
#show raw.where(block: true, lang: "python", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("python", it) }
#show raw.where(block: true, lang: "r", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("r", it) }
#show raw.where(block: true, lang: "mermaid", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("mermaid", it) }
#show raw.where(block: true, lang: "dot", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("dot", it) }
#show raw.where(block: true, lang: "tikz", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("tikz", it) }
#show raw.where(block: true, lang: "d2", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("d2", it) }
#show raw.where(block: true, lang: "sh", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("sh", it) }

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

#import "/_calepin/calepin.typ" as calepin_runtime
#import "/_calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": (
  example-source,
  thumbnail-gallery-items,
)

#set document(title: [Troubleshooting])
#metadata((
  title: "Troubleshooting",
  tags: ("help", "questions"),
)) <website-metadata>

#title()

= Where do slide margins go?

`setup` uses a zero page margin. Put content spacing on the cells with each cell's `inset`:

```typ
#show: m.setup

#let grid = m.grids.rows(
  m.grids.cell("a", inset: 1.5em),
  m.grids.columns(
    m.grids.cell("b", inset: 1.5em),
    m.grids.cell("c", inset: 1.5em),
  ),
)

#m.slide(layout: grid)[Top][Bottom left][Bottom right]
```

`inset` separates content from a cell's edges; adjacent cells each contribute their own inset. A grid `gutter` instead separates the cell surfaces and defaults to `0pt`.

= How do I change the slide aspect ratio?

Mosaic supports the two presentation aspect ratios built into Typst:

- `"16-9"` is the default widescreen format.
- `"4-3"` is the traditional format.

Choose one with the `paper` argument.

#example-source("faq/aspect-ratio-16-9")
#example-source("faq/aspect-ratio-4-3")

#thumbnail-gallery-items(
  calepin.elements.gallery,
  (
    (
      "/assets/examples/faq/aspect-ratio-16-9-1.svg",
      "A widescreen 16:9 slide",
      [16:9],
    ),
    (
      "/assets/examples/faq/aspect-ratio-4-3-1.svg",
      "A traditional 4:3 slide",
      [4:3],
    ),
  ),
)

= How do I inspect overflowing cells?

Mosaic records a warning when a cell's content is taller than the cell. Query those records with:

#calepin_runtime.chunk_from_raw_plain("sh", raw("  'query(<mosaic-overflow-warning>).map(it => it.value)' \\\n  --in slides.typ\n", block: true, lang: "sh"))

Each record identifies the slide, frame, cell, and measured height. Set `setup(overflow: "error")` to fail the compile instead, naming every overflowing cell with the same slide and frame numbers the query reports, or `setup(overflow: "off")` to turn the check off; see the
#link("../api/setup.html")[Setup API].

To make the content fit instead of reporting it, give the cell a `fit:` mode: `m.layouts.content(fit: "auto")` scales and reflows a body column into the available space, and `m.grids.cell(id, fit: ...)` does the same for a hand-built cell. Fitted cells never trigger the warning.

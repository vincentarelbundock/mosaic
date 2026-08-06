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
#import "/diagrams/grid-anatomy.typ": diagram as grid-anatomy
#import "/diagrams/slide-planes.typ": diagram as slide-planes

#set document(title: [Concepts])
#metadata((title: "Concepts")) <website-metadata>

#title()

= Vocabulary

On this website, we will refer to the different components of a slide deck in these terms:

- *Slide*: one unit of a presentation.
- *Deck*: a sequence of slides.
- *Cell*: a named area that holds content.
- *Grid*: the arrangement of cells you build yourself, with horizontal and vertical splits.
- *Split*: a horizontal or vertical division between cells, built with `columns` or `rows`.
- *Track*: the width or height assigned to one child of a split.
- *Inset*: space between a cell's edge and its content.
- *Plane*: a full-slide layer drawn outside the grid. Every slide has two.
- *Background*: the plane drawn behind the grid.
- *Foreground*: the plane drawn over the grid.
- *Layout*: a grid Mosaic already built for a familiar slide kind, supplying fixed content or decoration when that kind needs it.
- *Variant*: a named alternative arrangement offered by a layout.
- *Component*: a reusable piece of slide content such as a callout, quote, or badge.
- *Theme*: a coordinated set of colors, text styles, and layouts.
- *Step*: one stage of a slide's timed build. Each step renders as its own frame.
- *Frame*: one page of the compiled document; a slide with timed content spans several frames.

= Anatomy of a slide deck

#html.elem("div", attrs: (class: "mosaic-diagram"), html.frame(grid-anatomy))\
#v(1em)

The grid is sandwiched between two full-slide planes. The *background* plane is painted behind the cells. It typically holds a full-slide image, a color wash, or a watermark. The *foreground* plane is painted over the cells. It typically holds a slide number, a logo, or a progress indicator. Neither plane takes space away from the grid. The #link("../slides/background.html")[Background] and #link("../slides/foreground.html")[Foreground] pages show how to use them.

#v(1em)\
#html.elem("div", attrs: (class: "mosaic-diagram"), html.frame(slide-planes))
#v(1em)\

Where a grid is the structure you build, a *layout* is one Mosaic has already built for a familiar slide kind. Mosaic ships layouts for #link("../slides/content.html")[content], #link("../slides/title.html")[titles], #link("../slides/section.html")[sections], and #link("../slides/image.html")[images]; each offers several named *variants* of its arrangement. #link("../slides/custom.html")[Custom slides] build a grid instead.

Every cell, the background, and the foreground is a native Typst layer, and each one carries a *label*: `<mosaic-cell-ID>`, `<mosaic-background>`, and `<mosaic-foreground>`. Ordinary Typst `show` and `set` rules can therefore style every part of a slide. See #link("../appearance/styling.html")[Styling cells] for a detailed tutorial.

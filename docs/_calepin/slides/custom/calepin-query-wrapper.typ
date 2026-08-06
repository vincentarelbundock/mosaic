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
#import "/_includes/embedded-examples.typ": embedded-example, thumbnail-gallery
#import "/_includes/pdf-slideshow.typ": pdf-slideshow
#import "/_includes/site.typ": asset-url

#set document(title: [Custom slides])
#metadata((title: "Custom")) <website-metadata>

// One step of the canonical semantic-slide example, shown through the same
// PDF slideshow treatment as every other embedded example. The preview image
// is that step's frame; the dialog pages through the whole walkthrough.
#let semantic-frames = 5
#let semantic-thumbnail(frame, alt) = {
  if sys.inputs.at("calepin-target", default: "paged") == "html" {
    pdf-slideshow(
      asset-url("assets/examples/basics/semantic-slide.pdf"),
      asset-url(
        "assets/examples/basics/semantic-slide-" + str(frame) + ".svg",
      ),
      "pdf-slideshow-basics-semantic-slide-" + str(frame),
      alt,
      semantic-frames,
      alt + ", step " + str(frame) + " of " + str(semantic-frames),
    )
  } else {
    thumbnail-gallery(
      calepin.elements.gallery,
      "basics/semantic-slide",
      1,
      alt,
      start: frame,
      columns: 1,
      show-captions: false,
    )
  }
}

#title()

When no built-in layout fits, write the slide's arrangement yourself. A custom slide names its own cells by purpose, such as `header`, `body`, `footer`, `aside`, or `notes`. This is *semantic* structure: content and styling refer to what each cell means instead of where it appears.

Build a custom slide in three separate layers: define its named grid, assign content to those names, and style the labeled cells with native Typst rules. The walkthrough below grows one slide through all three. The sections after it are the reference for each layer.

= Walkthrough

== One named cell

Start with one named cell and pass it to `slide` as the layout.

```typ
#let single = m.grids.cell("main")

#m.slide(
  layout: single,
  cells: (main: [A custom slide starts with one named cell.]),
)
```

#semantic-thumbnail(1, "A slide containing one named cell")

== Split the grid

`m.grids.columns` places cells side by side. Each key in `cells:` matches one cell ID.

```typ
#let split = m.grids.columns("main", "aside")

#m.slide(
  layout: split,
  cells: (
    main: [The main argument],
    aside: [Supporting evidence],
  ),
)
```

#semantic-thumbnail(2, "The slide split into two equal columns")

== Nest splits and size tracks

Splits nest directly: `rows` stacks the sidebar cells, `track` assigns their proportions, and `columns` combines the sidebar with the main cell.

```typ
#let composition = m.grids.columns(
  m.grids.track(2fr, "main"),
  m.grids.track(1fr, m.grids.rows(
    m.grids.track(2fr, "notes"),
    m.grids.track(1fr, "source"),
  )),
)

#m.slide(
  layout: composition,
  cells: (
    main: [The main argument],
    notes: [Two parts notes],
    source: [One part source],
  ),
)
```

#semantic-thumbnail(3, "A two-thirds main cell beside a vertically split sidebar")

== Add content

The grid remains unchanged while the `cells:` dictionary receives ordinary Typst markup: headings, lists, emphasis, figures, equations, or any custom content.

```typ
#m.slide(
  layout: composition,
  cells: (
    main: [
      == Composition

      - Name every cell.
      - Keep structure independent of content.
    ],
    notes: [
      *Evidence*

      #lorem(8)
    ],
    source: [#text(size: 0.65em)[Source: example data]],
  ),
)
```

#semantic-thumbnail(4, "The grid filled with ordinary Typst content")

== Style the cells

Once the cells and content are in place, target each cell by its label. `m.surface` paints the cell, while `set align` positions its content.

```typ
#show label("mosaic-cell-main"): m.surface(fill: rgb("#7fa8cc"))
#show label("mosaic-cell-main"): set align(left + horizon)
#show label("mosaic-cell-notes"): m.surface(fill: rgb("#85b892"))
#show label("mosaic-cell-source"): m.surface(fill: rgb("#c9a75e"))
```

See #link("../appearance/styling.html#content-rules-and-surface-rules")[Styling cells] for the full styling model.

== Built-in layouts are grids too

A built-in layout resolves to a grid of named cells like any other, so the same `cells:` dictionary fills it. Assign one to a binding and pass it as the layout when you want a familiar structure without giving up named assignment:

```typ
#let content-layout = m.layouts.content(variant: "header-body")

#m.slide(
  layout: content-layout,
  cells: (
    header: [== Content layout],
    body: [A familiar header-and-body structure.],
  ),
)
```

#semantic-thumbnail(5, "A built-in content layout filled through named cells")

= Grids with `columns()` and `rows()`

Describe a custom grid by splitting the available space. `m.grids.columns` places cells side by side; `m.grids.rows` stacks them. Each string is a cell ID. Import Mosaic under a short alias so the grid constructors stay namespaced and native Typst `columns()` remains available:

```typ
#import "@local/mosaic:0.0.1" as m
```

Assign the grid to a binding, then pass it to `m.slide` through `layout:`. The slide's positional bodies fill the cells in source order:

#embedded-example(
  calepin.elements.gallery,
  "structure/grid-columns",
  title: "Three equal-width columns",
  renderer: thumbnail-gallery,
  columns: 1,
  show-captions: false,
)

Use `m.grids.rows` for equal-height rows instead:

#embedded-example(
  calepin.elements.gallery,
  "structure/grid-rows",
  title: "Three equal-height rows",
  renderer: thumbnail-gallery,
  columns: 1,
  show-captions: false,
)

Each example on this page outlines its cells so the structure is visible. Those outlines are nothing but ordinary label rules, described in #link("../appearance/styling.html")[Styling cells]: they open every listing and are no part of the grid, which is the `#m.grids` tree alone.

= Nesting

Any child of a split can be another grid, so a region can carry its own division. Here the outer `columns` gives `a` the left half and stacks `b` and `c` on the right:

#embedded-example(
  calepin.elements.gallery,
  "structure/grid-nested",
  title: "One column beside a stacked pair",
  renderer: thumbnail-gallery,
  columns: 1,
  show-captions: false,
)

Two stacked `columns` splits make a 2 x 2 arrangement:

#embedded-example(
  calepin.elements.gallery,
  "structure/grid-quadrants",
  title: "A two-by-two arrangement",
  renderer: thumbnail-gallery,
  columns: 1,
  show-captions: false,
)

Splits nest to any depth. Read a grid from the outside inward: choose the largest split first, then replace any child that needs another division with a nested `columns` or `rows`. Keep descriptive IDs and indentation so the tree stays visible in source:

#embedded-example(
  calepin.elements.gallery,
  "structure/grid-dashboard",
  title: "Three bands, the middle one divided twice",
  renderer: thumbnail-gallery,
  columns: 1,
  show-captions: false,
)

= Grid sizes (tracks)

By default, every direct child of `m.grids.columns` or `m.grids.rows` receives a `1fr` track. Wrap a child with `m.grids.track` when it needs another size:

#embedded-example(
  calepin.elements.gallery,
  "structure/grid-track-fraction",
  title: "A two-thirds split",
  renderer: thumbnail-gallery,
  columns: 1,
  show-captions: false,
)

Tracks accept native `auto`, fixed lengths, percentages, and `fr` values:

#embedded-example(
  calepin.elements.gallery,
  "structure/grid-track-banner",
  title: "A fixed-height banner over a body",
  renderer: thumbnail-gallery,
  columns: 1,
  show-captions: false,
)

Fractions compose, so three tracks can center a double-width column:

#embedded-example(
  calepin.elements.gallery,
  "structure/grid-track-center",
  title: "A centered double-width column",
  renderer: thumbnail-gallery,
  columns: 1,
  show-captions: false,
)

The #link("../api/grids.html")[Grid API] lists the exact accepted forms and their diagnostics.

Content reaches a custom grid the same two ways it reaches any layout: positional bodies in traversal order, or the named `cells:` dictionary the walkthrough above uses. #link("configuring.html#filling-cells")[Filling cells] states the exact rules, including fixed cell content declared on the cell itself.

A cell does not resize its content: a body larger than its cell is drawn past the edge. #link("../presenting/overflow.html")[Overflow and fitting] covers how to detect that and how `m.fit` scales one block into the space its cell gives it.

Cells hold ordinary Typst content. The #link("../content/images.html")[Content] section collects what most often goes inside them: images, the reusable `m.components` library, and math.

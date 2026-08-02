#import "@local/mosaic:0.0.1" as mosaic
#import "support/grid.typ" as grid-test

#set page(width: 160pt, height: 90pt, margin: 5pt)
// Composable grid construction and bounded grid introspection.
#assert(mosaic.grid.h("a", "b").gutter == 0pt)
#assert(mosaic.grid.h(gutter: 1em, "a", "b").gutter == 1em)
#assert(grid-test.count(mosaic.grid.v(mosaic.grid.h("a", "b"), mosaic.grid.h("c", "d"))) == 4)
#assert(
  grid-test.count(
    mosaic.grid.h(mosaic.grid.v("a", "b"), mosaic.grid.v("c", "d"), mosaic.grid.v("e", "f", "g")),
  ) == 7,
)

// Public cell introspection uses required string names. Track
// descriptors identify the parent path, local child, value, and every leaf
// affected by that track.
#let stacked = mosaic.grid.v("a", "b")
#let first-row = grid-test.info(stacked, "a")
#assert(first-row.id == "a")
#assert(first-row.path == (0,))
#assert(first-row.tracks.len() == 1)
#assert(first-row.tracks.at(0).axis == "height")
#assert(first-row.tracks.at(0).path == ())
#assert(first-row.tracks.at(0).child == 0)
#assert(first-row.tracks.at(0).value == 1fr)
#assert(first-row.tracks.at(0).affects == ("a",))
#assert(grid-test.info(stacked, "b").id == "b")

// Track sizes and insets are structural; appearance comes from native rules
// targeting each cell's <mosaic-cell-ID> label.
#let pink = rgb("#f8dce5")
#let configured = mosaic.grid.v(
  mosaic.grid.t(
    auto,
    mosaic.grid.cell("banner", inset: 4pt),
  ),
  mosaic.grid.cell("body", inset: 4pt),
)
#assert(configured.tracks == (auto, 1fr))
#assert(grid-test.info(configured, "banner").cell.id == "banner")
#assert(grid-test.info(configured, "banner").cell.style.inset == 4pt)

// Nested cells expose both controlling axes. A parent track can affect more
// than one leaf, while the nested perpendicular track remains cell-specific.
#let top-bottom = mosaic.grid.v("a", mosaic.grid.h("b", "c"))
#let bottom-left = grid-test.info(top-bottom, "b")
#assert(bottom-left.path == (1, 0))
#assert(bottom-left.tracks.len() == 2)
#assert(bottom-left.tracks.at(0).axis == "height")
#assert(bottom-left.tracks.at(0).affects == ("b", "c"))
#assert(bottom-left.tracks.at(1).axis == "width")
#assert(bottom-left.tracks.at(1).affects == ("b",))

// Temporal wrappers do not add an artificial step to the child path.
#let temporal-grid = mosaic.grid.v(
  mosaic.grid.t(auto, mosaic.steps.on("2-", mosaic.grid.cell(id: "first"))),
  "second",
)
#let temporal-info = grid-test.info(temporal-grid, "first")
#assert(temporal-info.path == (0,))
#assert(temporal-info.tracks.at(0).affects == ("first",))
#assert(temporal-grid.tracks == (auto, 1fr))

// A fixed image cell owns content; appearance stays native.
#let image-grid = mosaic.grid.h(
  mosaic.grid.t(
    30%,
    mosaic.grid.cell(
      id: "image",
      inset: 0pt,
      content: image(
        "../docs/assets/images/mosaic-logo.svg",
        width: 100%,
        height: 100%,
        fit: "contain",
        alt: "Mosaic logo",
      ),
    ),
  ),
  mosaic.grid.cell("text"),
)
#let image-info = grid-test.info(image-grid, "image")
#assert(image-info.cell.content != none)
#assert(image-info.cell.style.inset == 0pt)

// Set the deck-wide default; slides can still override it explicitly.
#show: mosaic.setup.with(
  spacing: (inset: 5pt),
  default-grid: mosaic.grid.h("a", "b"),
)
#set text(size: 7pt)

// Page 1: deck-default grid plus native show rules, headings, figures,
// and citations.
#show heading.where(level: 2): set text(fill: blue, weight: "bold")
#mosaic.slide[
  == One
  Native Typst content #cite(<mosaic-test>).
  #figure(
    rect(width: 20pt, height: 8pt, fill: gray),
    caption: [Native figure],
  )
  #bibliography("refs.bib", title: none)
][
  The second cell comes from the deck-wide default grid.
]

// Page 2: equal vertical splits, mixed inner tracks, and depth-first bodies.
#let nested = mosaic.grid.v(
  "top",
  mosaic.grid.h(
    gutter: 2pt,
    "left",
    mosaic.grid.t(20pt, mosaic.grid.v("middle-top", "middle-bottom")),
    mosaic.grid.t(auto, "right"),
  ),
)
#mosaic.slide(grid: nested)[1][2][3][4][5]

// Page 3: an explicit single-cell override containing a native grid.
#mosaic.slide(grid: mosaic.grid.cell(id: "body"))[
  #grid(
    columns: (1fr, 1fr),
    rows: (1fr, 1fr),
    [A], [B], [C], [D],
  )
]

// Page 4: label-targeted rules style both fixed and supplied cell content;
// scoping them in a block limits them to this one slide.
#let text-grid = mosaic.grid.v(
  mosaic.grid.cell(
    id: "fixed",
    content: [Fixed content],
  ),
  mosaic.grid.cell("supplied"),
)
#[
  #show label("mosaic-cell-fixed"): set text(size: 0.8em, fill: blue)
  #show label("mosaic-cell-supplied"): set text(size: 1.2em, weight: "bold")
  #mosaic.slide(text-grid)[Supplied content]
]

// Fixed cell content is declared directly, so only the remaining cell consumes
// a slide body. Fills and alignment are native label rules.
#[
  #show label("mosaic-cell-a"): it => block(
    width: 100%,
    height: 100%,
    fill: white,
    it,
  )
  #show label("mosaic-cell-b"): set align(center + horizon)
  #show label("mosaic-cell-b"): it => block(
    width: 100%,
    height: 100%,
    fill: pink,
    it,
  )
  #mosaic.slide(mosaic.grid.h(
    mosaic.grid.t(
      30%,
      mosaic.grid.cell(
        id: "a",
        inset: 2pt,
        content: image(
          "../docs/assets/images/mosaic-logo.svg",
          width: 100%,
          height: 100%,
          fit: "contain",
          alt: "Mosaic logo",
        ),
      ),
    ),
    mosaic.grid.cell("b"),
  ))[Configured grid]

  #mosaic.slide(mosaic.grid.h(
    mosaic.grid.cell("a"),
    mosaic.grid.cell("b"),
  ))[A][B]
]

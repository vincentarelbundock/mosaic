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

// Track sizes are structural; named cell surfaces are supplied to the slide.
#let pink = rgb("#f8dce5")
#let configured = mosaic.grid.v(
  mosaic.grid.t(
    auto,
    mosaic.grid.cell("title"),
  ),
  mosaic.grid.cell("body"),
)
#let configured-styles = (
  title: (
    fill: pink,
    inset: 4pt,
    text: (size: 1.2em, fill: blue, weight: "bold"),
  ),
  body: (inset: 4pt, stroke: 0.5pt + gray),
)
#assert(configured.tracks == (auto, 1fr))
#assert(grid-test.info(configured, "title").cell.id == "title")
#assert(configured-styles.title.fill == pink)
#assert(configured-styles.title.inset == 4pt)
#assert(configured-styles.title.text.size == 1.2em)
#assert(configured-styles.title.text.fill == blue)
#assert(configured-styles.title.text.weight == "bold")
#assert(configured-styles.body.stroke == 0.5pt + gray)

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
  mosaic.grid.t(auto, mosaic.on("2-", mosaic.grid.cell(id: "first"))),
  "second",
)
#let temporal-info = grid-test.info(temporal-grid, "first")
#assert(temporal-info.path == (0,))
#assert(temporal-info.tracks.at(0).affects == ("first",))
#assert(temporal-grid.tracks == (auto, 1fr))

// A fixed image cell owns content; its slide owns named surface styles.
#let image-grid = mosaic.grid.h(
  mosaic.grid.t(
    30%,
    mosaic.grid.cell(
      id: "image",
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
#let image-styles = (
  image: (inset: 0pt, fill: white),
  text: (align: center + horizon, fill: pink),
)
#let image-info = grid-test.info(image-grid, "image")
#assert(image-info.cell.content != none)
#assert(image-styles.image.inset == 0pt)
#assert(image-styles.image.fill == white)

// Set the deck-wide default; slides can still override it explicitly.
#show: mosaic.setup.with(
  spacing: (inset: 5pt),
)
#set text(size: 7pt)

#mosaic.deck(default-grid: mosaic.grid.h("a", "b"))

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

// Page 4: named text styles apply to both fixed and supplied cell content.
#let text-grid = mosaic.grid.v(
  mosaic.grid.cell(
    id: "fixed",
    content: [Fixed content],
  ),
  mosaic.grid.cell("supplied"),
)
#mosaic.slide(
  text-grid,
  cell-styles: (
    fixed: (text: (size: 0.8em, fill: blue)),
    supplied: (text: (size: 1.2em, weight: "bold")),
  ),
)[Supplied content]

// Fixed cell content is declared directly, so only the remaining cell consumes
// a slide body.
#mosaic.slide(mosaic.grid.h(
  mosaic.grid.t(
    30%,
    mosaic.grid.cell(
      id: "a",
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
), cell-styles: (
  a: (inset: 2pt, fill: white),
  b: (align: center + horizon, fill: pink),
))[Configured grid]

#mosaic.slide(mosaic.grid.h(
  mosaic.grid.cell("a"),
  mosaic.grid.cell("b"),
), cell-styles: (
  a: (fill: pink),
  b: (fill: white),
))[A][B]

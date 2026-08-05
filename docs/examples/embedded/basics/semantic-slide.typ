#import "@local/mosaic:0.0.1" as m

#show: m.setup

// Tint every named cell used below ahead of time, one native show rule per
// cell label, so each step's grid structure is visible from the start.
// m.surface paints the cell's own block; set rules style the content inside.
#show label("mosaic-cell-main"): m.surface(fill: rgb("#7fa8cc"))
#show label("mosaic-cell-main"): set align(left + horizon)
#show label("mosaic-cell-aside"): m.surface(fill: rgb("#c9a75e"))
#show label("mosaic-cell-aside"): set align(left + horizon)
#show label("mosaic-cell-notes"): m.surface(fill: rgb("#85b892"))
#show label("mosaic-cell-notes"): set align(left + horizon)
#show label("mosaic-cell-source"): m.surface(fill: rgb("#c9a75e"))
#show label("mosaic-cell-source"): set align(left + horizon)

// Start with one named cell.
#let single = m.grids.cell("main")

#m.slide(
  layout: single,
  cells: (main: [A semantic slide starts with one named cell.]),
)

// Split the same slide into two equal columns.
#let split = m.grids.columns("main", "aside")

#m.slide(
  layout: split,
  cells: (
    main: [The main argument],
    aside: [Supporting evidence],
  ),
)

// Add nested rows and explicit track proportions.
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

// Fill those stable cell IDs with ordinary Typst content.
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

// Built-in layouts resolve to grids: assign one before passing it to slide.
#let content-layout = m.layouts.content(variant: "header-body")
#m.slide(
  layout: content-layout,
  cells: (
    header: [== Content layout],
    body: [A familiar header-and-body structure.],
  ),
)

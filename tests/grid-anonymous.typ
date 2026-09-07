#import "@local/mosaic:0.0.2" as mosaic
#import "support/grid.typ" as grid-test

#set page(width: 160pt, height: 90pt, margin: 5pt)

// An `auto` child is an anonymous cell named by its one-based position.
#assert(grid-test.cell-ids(mosaic.grids.columns(auto, auto, auto)) == ("1", "2", "3"))

// Placing a split in a split grows the names into paths; authored ids stay.
#let nested = mosaic.grids.rows(
  mosaic.grids.columns(auto, auto),
  mosaic.grids.columns(auto, "aside", auto),
)
#assert(grid-test.cell-ids(nested) == ("1-1", "1-2", "2-1", "aside", "2-3"))
#assert(grid-test.count(nested) == 5)
#assert(grid-test.bodies(nested) == 5)

// Paths grow through tracks and incremental wrappers alike.
#let deep = mosaic.grids.columns(
  mosaic.grids.track(2fr, mosaic.grids.rows(auto, mosaic.grids.columns(auto, auto))),
  mosaic.steps.on("2-", mosaic.grids.rows(auto, "named")),
)
#assert(grid-test.cell-ids(deep) == ("1-1", "1-2-1", "1-2-2", "2-1", "named"))

// A subtree built on its own keeps local names until it is placed.
#let pair = mosaic.grids.columns(auto, auto)
#assert(grid-test.cell-ids(pair) == ("1", "2"))
#assert(grid-test.cell-ids(mosaic.grids.rows("top", pair)) == ("top", "2-1", "2-2"))

// Path names sit in the same tree positions as authored ones.
#assert(grid-test.info(nested, "2-3").path == (1, 2))
#assert(grid-test.info(nested, "2-3").tracks.at(1).axis == "width")

#show: mosaic.setup.with(spacing: (inset: 5pt))
#set text(size: 7pt)

// Page 1: bodies fill anonymous cells depth-first like named ones, and a
// path is a label like any other.
#show label("mosaic-cell-2-2"): set text(fill: blue, weight: "bold")
#mosaic.slide(layout: mosaic.grids.rows(
  mosaic.grids.columns(auto, auto, auto),
  mosaic.grids.columns(auto, auto),
))[one][two][three][four][five]

// Page 2: named assignment addresses an anonymous cell by its path and may
// skip the others.
#mosaic.slide(layout: nested, cells: ("1-1": [first], aside: [aside], "2-3": [last]))

// Named cell content: `cells:` assigns content by cell ID, independent of
// grid traversal order. Positional content remains the terse shorthand; both
// normalize to one ordered body array, so equivalent slides render identically.
#import "@local/mosaic:0.0.3" as mosaic
#import "../mosaic/src/grid/content.typ": body-cell-ids, resolve-content

#let comparison = mosaic.grids.columns(
  mosaic.grids.rows(
    mosaic.grids.cell("heading"),
    mosaic.grids.cell("left"),
  ),
  mosaic.grids.cell("right"),
)

// Content-bearing IDs follow the grid's depth-first declaration order.
#assert(body-cell-ids(comparison) == ("heading", "left", "right"))

// Named and positional content resolve to the same id -> content map, so
// dictionary order is irrelevant and the two forms are equivalent.
#let named = resolve-content(comparison, (
  right: [Right],
  heading: [Heading],
  left: [Left],
), ())
#let positional = resolve-content(comparison, (:), ([Heading], [Left], [Right]))
#assert(named == (heading: [Heading], left: [Left], right: [Right]))
#assert(named == positional)

// The slide command carries the content dictionary. `slide` returns the
// command record followed by the guard that fails outside a deck.
#let command = mosaic.slide(layout: comparison, cells: (
  heading: [H],
  left: [L],
  right: [R],
)).children.first().value
#assert(command.cells.keys().sorted() == ("heading", "left", "right"))
#assert(command.bodies == ())

// A fixed-content cell is owned by the grid and is not a named destination.
#let with-fixed = mosaic.grids.columns(
  mosaic.grids.cell("logo", content: [LOGO]),
  mosaic.grids.cell("body"),
)
#assert(body-cell-ids(with-fixed) == ("body",))
#assert(resolve-content(with-fixed, (body: [Body]), ()) == (body: [Body]))

// Every open cell is optional when content is named, and a slide with no
// positional bodies at all is empty. Positional bodies are counted strictly:
// a partial list is an error (tests/invalid/slide-bodies-too-few.typ).
#assert(
  resolve-content(comparison, (right: [Right]), ())
    == (heading: [], left: [], right: [Right]),
)
#assert(
  resolve-content(comparison, (:), ())
    == (heading: [], left: [], right: []),
)

// Incremental destinations are counted by ID too.
#let temporal = mosaic.grids.rows(
  mosaic.grids.cell("top"),
  mosaic.steps.on("2-", mosaic.grids.cell("bottom")),
)
#assert(body-cell-ids(temporal) == ("top", "bottom"))

#set page(width: 240pt, height: 135pt, margin: 0pt)
#show: mosaic.setup

// Named and equivalent positional slides render identically.
#mosaic.slide(layout: comparison, cells: (
  right: [Right],
  heading: [Heading],
  left: [Left],
))
#mosaic.slide(layout: comparison)[Heading][Left][Right]

// Named content into a fixed-cell grid supplies only the open cell.
#mosaic.slide(layout: with-fixed, cells: (body: [Body]))

// Named content flows through incremental cells.
#mosaic.slide(layout: temporal, cells: (top: [Top], bottom: [Bottom]))

// A `none` positional body is an empty cell: it is what a conditional yields
// when its branch is not taken.
#mosaic.slide(layout: comparison, none, [Left only], if false [Never])

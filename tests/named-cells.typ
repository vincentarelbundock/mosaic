// Named cell content: `cells:` assigns content by cell ID, independent of
// grid traversal order. Positional content remains the terse shorthand; both
// normalize to one ordered body array, so equivalent slides render identically.
#import "@local/mosaic:0.0.1" as mosaic
#import "../mosaic/src/grid-model.typ": body-cell-ids, resolve-named-content

#let comparison = mosaic.grid.h(
  mosaic.grid.v(
    mosaic.grid.cell("heading"),
    mosaic.grid.cell("left"),
  ),
  mosaic.grid.cell("right"),
)

// Content-bearing IDs follow the grid's depth-first declaration order.
#assert(body-cell-ids(comparison) == ("heading", "left", "right"))

// Named assignment is independent of dictionary order and resolves to the
// same ordered array the positional form produces.
#let positional = ([Heading], [Left], [Right])
#let named = resolve-named-content(comparison, (
  right: [Right],
  heading: [Heading],
  left: [Left],
))
#assert(repr(named) == repr(positional))

// The slide command carries the cells dictionary.
#let command = mosaic.slide(comparison, cells: (
  heading: [H],
  left: [L],
  right: [R],
)).value
#assert(command.cells.keys().sorted() == ("heading", "left", "right"))
#assert(command.bodies == ())

// A fixed-content cell is owned by the grid and is not a named destination.
#let with-fixed = mosaic.grid.h(
  mosaic.grid.cell("logo", content: [LOGO]),
  mosaic.grid.cell("body"),
)
#assert(body-cell-ids(with-fixed) == ("body",))
#assert(resolve-named-content(with-fixed, (body: [Body])) == ([Body],))

// Incremental destinations are counted by ID too.
#let temporal = mosaic.grid.v(
  mosaic.grid.cell("top"),
  mosaic.on("2-", mosaic.grid.cell("bottom")),
)
#assert(body-cell-ids(temporal) == ("top", "bottom"))

#set page(width: 240pt, height: 135pt, margin: 0pt)
#show: mosaic.setup

// Named and equivalent positional slides render identically.
#mosaic.slide(comparison, cells: (
  right: [Right],
  heading: [Heading],
  left: [Left],
))
#mosaic.slide(comparison)[Heading][Left][Right]

// Named content into a fixed-cell grid supplies only the open cell.
#mosaic.slide(with-fixed, cells: (body: [Body]))

// Named content flows through incremental cells.
#mosaic.slide(temporal, cells: (top: [Top], bottom: [Bottom]))

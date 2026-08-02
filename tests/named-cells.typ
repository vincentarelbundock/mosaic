// Named cell content: `content:` assigns content by cell ID, independent of
// grid traversal order. Positional content remains the terse shorthand; both
// normalize to one ordered body array, so equivalent slides render identically.
#import "@local/mosaic:0.0.1" as mosaic
#import "../mosaic/src/grid-model.typ": body-cell-ids, resolve-content

#let comparison = mosaic.grid.h(
  mosaic.grid.v(
    mosaic.grid.cell("heading"),
    mosaic.grid.cell("left"),
  ),
  mosaic.grid.cell("right"),
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

// The slide command carries the content dictionary.
#let command = mosaic.slide(comparison, content: (
  heading: [H],
  left: [L],
  right: [R],
)).value
#assert(command.content.keys().sorted() == ("heading", "left", "right"))
#assert(command.bodies == ())

// A fixed-content cell is owned by the grid and is not a named destination.
#let with-fixed = mosaic.grid.h(
  mosaic.grid.cell("logo", content: [LOGO]),
  mosaic.grid.cell("body"),
)
#assert(body-cell-ids(with-fixed) == ("body",))
#assert(resolve-content(with-fixed, (body: [Body]), ()) == (body: [Body]))

// Incremental destinations are counted by ID too.
#let temporal = mosaic.grid.v(
  mosaic.grid.cell("top"),
  mosaic.steps.on("2-", mosaic.grid.cell("bottom")),
)
#assert(body-cell-ids(temporal) == ("top", "bottom"))

#set page(width: 240pt, height: 135pt, margin: 0pt)
#show: mosaic.setup

// Named and equivalent positional slides render identically.
#mosaic.slide(comparison, content: (
  right: [Right],
  heading: [Heading],
  left: [Left],
))
#mosaic.slide(comparison)[Heading][Left][Right]

// Named content into a fixed-cell grid supplies only the open cell.
#mosaic.slide(with-fixed, content: (body: [Body]))

// Named content flows through incremental cells.
#mosaic.slide(temporal, content: (top: [Top], bottom: [Bottom]))

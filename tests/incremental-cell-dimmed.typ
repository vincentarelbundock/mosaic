#import "@local/mosaic:0.0.3" as m

// A component in a cell under a dimmed grid node mutes its own paint, as one
// under a dimmed step in a body does. Three placements: a dimmed cell, a cell
// below a dimmed split, and a dimmed cell inside a split in an `auto` row,
// which renders in two passes that must agree. Page 1 is the dimmed frame,
// page 2 the lit one; scripts/run-tests.py looks for the loud fills in each.
#show: m.setup.with(overflow: "off")

#let card(fill) = m.components.card(fill: fill, accent: fill)[CARD]

#m.slide(m.grids.rows(
  tracks: (auto, 1fr),
  m.grids.columns(
    tracks: (1fr, auto),
    "strip",
    m.steps.on(2, before: "dimmed", m.grids.cell("logo")),
  ),
  m.grids.columns(
    m.steps.on(2, before: "dimmed", m.grids.cell("cell")),
    m.steps.on(2, before: "dimmed", m.grids.rows("upper", "lower")),
  ),
))[Strip][#card(rgb("#00ff11"))][#card(rgb("#ff0011"))][#card(rgb("#1100ff"))][Lower]

#context assert(counter(page).final().first() == 2)

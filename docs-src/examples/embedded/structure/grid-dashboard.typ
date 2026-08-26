#import "@local/mosaic:0.0.2" as m
#show: m.setup

// Outline each cell so the grid structure is visible. Cells are structural, so
// these are ordinary label rules rather than a grid feature.
#let outline = 1pt + luma(65%)
#show label("mosaic-slide"): set align(center + horizon)
#show label("mosaic-slide"): set text(weight: "bold")
#show label("mosaic-cell-banner"): set block(stroke: outline)
#show label("mosaic-cell-sidebar"): set block(stroke: outline)
#show label("mosaic-cell-chart"): set block(stroke: outline)
#show label("mosaic-cell-legend"): set block(stroke: outline)
#show label("mosaic-cell-notes"): set block(stroke: outline)
#show label("mosaic-cell-status"): set block(stroke: outline)

// Splits nest to any depth. Read it from the outside inward: three bands, then
// the middle band divides again, and its right side divides once more.
#let dashboard = m.grids.rows(
  "banner",
  m.grids.columns(
    "sidebar",
    m.grids.rows("chart", m.grids.columns("legend", "notes")),
  ),
  "status",
)

#m.slide(layout: dashboard)[banner][sidebar][chart][legend][notes][status]

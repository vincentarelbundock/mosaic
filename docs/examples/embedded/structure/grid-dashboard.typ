#import "@local/mosaic:0.0.1" as m
#show: m.setup

// Outline each cell so the grid structure is visible. Cells are structural, so
// these are ordinary label rules rather than a grid feature.
#let outline = m.surface(stroke: 1pt + luma(65%))
#show label("mosaic-slide"): set align(center + horizon)
#show label("mosaic-slide"): set text(weight: "bold")
#show label("mosaic-cell-banner"): outline
#show label("mosaic-cell-sidebar"): outline
#show label("mosaic-cell-chart"): outline
#show label("mosaic-cell-legend"): outline
#show label("mosaic-cell-notes"): outline
#show label("mosaic-cell-status"): outline

// Splits nest to any depth. Read it from the outside inward: three bands, then
// the middle band divides again, and its right side divides once more.
#let dashboard = m.grids.v(
  "banner",
  m.grids.h(
    "sidebar",
    m.grids.v("chart", m.grids.h("legend", "notes")),
  ),
  "status",
)

#m.slide(layout: dashboard)[banner][sidebar][chart][legend][notes][status]

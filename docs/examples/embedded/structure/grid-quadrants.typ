#import "@local/mosaic:0.0.1" as m
#show: m.setup

// Outline each cell so the grid structure is visible. Cells are structural, so
// these are ordinary label rules rather than a grid feature.
#let outline = m.surface(stroke: 1pt + luma(65%))
#show label("mosaic-slide"): set align(center + horizon)
#show label("mosaic-slide"): set text(weight: "bold")
#show label("mosaic-cell-a"): outline
#show label("mosaic-cell-b"): outline
#show label("mosaic-cell-c"): outline
#show label("mosaic-cell-d"): outline

// Two stacked h() splits make a 2 x 2 arrangement.
#let quadrants = m.grid.v(
  m.grid.h("a", "b"),
  m.grid.h("c", "d"),
)

#m.slide(layout: quadrants)[a][b][c][d]

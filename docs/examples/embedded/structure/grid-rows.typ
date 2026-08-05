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

// The same three strings under v() stack into equal-height rows.
#let three-rows = m.grids.v("a", "b", "c")

#m.slide(layout: three-rows)[a][b][c]

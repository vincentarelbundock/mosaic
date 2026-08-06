#import "@preview/mosaic:0.0.1" as m
#show: m.setup

// Outline each cell so the grid structure is visible. Cells are structural, so
// these are ordinary label rules rather than a grid feature.
#let outline = m.surface(stroke: 1pt + luma(65%))
#show label("mosaic-slide"): set align(center + horizon)
#show label("mosaic-slide"): set text(weight: "bold")
#show label("mosaic-cell-a"): outline
#show label("mosaic-cell-b"): outline
#show label("mosaic-cell-c"): outline

// Three strings produce three equal-width columns.
#let three-columns = m.grids.columns("a", "b", "c")

#m.slide(layout: three-columns)[a][b][c]

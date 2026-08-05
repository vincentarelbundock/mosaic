#import "@local/mosaic:0.0.1" as m
#show: m.setup

// Outline each cell so the grid structure is visible. Cells are structural, so
// these are ordinary label rules rather than a grid feature.
#let outline = m.surface(stroke: 1pt + luma(65%))
#show label("mosaic-slide"): set align(center + horizon)
#show label("mosaic-slide"): set text(weight: "bold")
#show label("mosaic-cell-a"): outline
#show label("mosaic-cell-b"): outline

// t() sizes one child: "a" takes two thirds of the width, "b" keeps the
// default 1fr and receives the rest.
#let two-thirds = m.grids.h(m.grids.t(2fr, "a"), "b")

#m.slide(layout: two-thirds)[a][b]

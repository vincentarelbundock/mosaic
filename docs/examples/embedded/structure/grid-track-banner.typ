#import "@local/mosaic:0.0.1" as m
#show: m.setup

// Outline each cell so the grid structure is visible. Cells are structural, so
// these are ordinary label rules rather than a grid feature.
#let outline = m.surface(stroke: 1pt + luma(65%))
#show label("mosaic-slide"): set align(center + horizon)
#show label("mosaic-slide"): set text(weight: "bold")
#show label("mosaic-cell-a"): outline
#show label("mosaic-cell-b"): outline

// Tracks accept percentages and fixed lengths too: a 25% banner over a body
// that takes the remaining height.
#let banner = m.grids.rows(m.grids.track(25%, "a"), "b")

#m.slide(layout: banner)[a][b]

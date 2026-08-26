#import "@local/mosaic:0.0.2" as m
#show: m.setup

// Outline each cell so the grid structure is visible. Cells are structural, so
// these are ordinary label rules rather than a grid feature.
#let outline = 1pt + luma(65%)
#show label("mosaic-slide"): set align(center + horizon)
#show label("mosaic-slide"): set text(weight: "bold")
#show label("mosaic-cell-a"): set block(stroke: outline)
#show label("mosaic-cell-b"): set block(stroke: outline)
#show label("mosaic-cell-c"): set block(stroke: outline)

// Any child can be another grid: the outer split gives "a" the left half, and
// a nested vertical split stacks "b" and "c" on the right.
#let nested = m.grids.columns("a", m.grids.rows("b", "c"))

#m.slide(layout: nested)[a][b][c]

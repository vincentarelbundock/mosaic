#import "@local/mosaic:0.0.3" as m
#show: m.setup

// Outline each cell so the grid structure is visible. Cells are structural, so
// these are ordinary label rules rather than a grid feature.
#let outline = 1pt + luma(65%)
#show label("mosaic-slide"): set align(center + horizon)
#show label("mosaic-slide"): set text(weight: "bold")
#show label("mosaic-cell-a"): set block(stroke: outline)
#show label("mosaic-cell-b"): set block(stroke: outline)

// tracks: gives one size per child, in order: "a" takes two thirds of the
// width and "b" the remaining third.
#let two-thirds = m.grids.columns(tracks: (2fr, 1fr), "a", "b")

#m.slide(layout: two-thirds)[a][b]

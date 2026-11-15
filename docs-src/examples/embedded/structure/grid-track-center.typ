#import "@local/mosaic:0.0.3" as m
#show: m.setup

// Outline each cell so the grid structure is visible. Cells are structural, so
// these are ordinary label rules rather than a grid feature.
#let outline = 1pt + luma(65%)
#show label("mosaic-slide"): set align(center + horizon)
#show label("mosaic-slide"): set text(weight: "bold")
#show label("mosaic-cell-a"): set block(stroke: outline)
#show label("mosaic-cell-b"): set block(stroke: outline)
#show label("mosaic-cell-c"): set block(stroke: outline)

// Fractions compose: 1fr + 2fr + 1fr centers a double-width column.
#let center-stage = m.grids.columns(tracks: (1fr, 2fr, 1fr), "a", "b", "c")

#m.slide(layout: center-stage)[a][b][c]

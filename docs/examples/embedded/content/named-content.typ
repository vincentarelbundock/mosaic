#import "@local/mosaic:0.0.1" as m

#show: m.setup

// Styling follows cell IDs, just like named content assignment.
#show label("mosaic-cell-heading"): m.surface(fill: rgb("#e8f1fb"))
#show label("mosaic-cell-left"): m.surface(fill: rgb("#e8f5ec"))
#show label("mosaic-cell-right"): m.surface(fill: rgb("#f7f0dd"))
#show label("mosaic-cell-heading"): set align(center + horizon)
#show label("mosaic-cell-left"): set align(center + horizon)
#show label("mosaic-cell-right"): set align(center + horizon)

#let comparison = m.grids.h(
  m.grids.v("heading", "left"),
  "right",
)

#m.slide(
  layout: comparison,
  content: (
    heading: [Heading],
    left: [Left argument],
    right: [Right argument],
  ),
)

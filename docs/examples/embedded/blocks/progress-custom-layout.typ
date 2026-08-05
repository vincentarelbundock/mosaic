#import "@local/mosaic:0.0.1" as m

#show: m.setup

#let slide-grid = m.grids.h(
  m.grids.cell("left"),
  m.grids.cell("right"),
)

// The two panels share a centered, bold look; the right one is tinted. Both
// are native rules on the structural cells' labels.
#show label("mosaic-cell-left"): set align(center + horizon)
#show label("mosaic-cell-left"): set text(size: 2em, weight: "bold")
#show label("mosaic-cell-right"): set align(center + horizon)
#show label("mosaic-cell-right"): set text(size: 2em, weight: "bold")
#show label("mosaic-cell-right"): it => block(
  width: 100%,
  height: 100%,
  fill: luma(94%),
  it,
)

#let slide-progress(left-body, right-body) = m.slide(
  layout: slide-grid,
  content: (foreground: place(
    bottom + left,
    block(width: 100%)[
      #m.components.progress(
        variant: "line",
        accent: black,
        fill: white,
        thickness: 8pt,
      )
    ],
  )),
  ..(left-body, right-body),
)

#slide-progress()[1a][1b]
#slide-progress()[2a][2b]
#slide-progress()[3a][3b]

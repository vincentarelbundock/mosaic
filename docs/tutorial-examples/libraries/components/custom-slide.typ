#import "@local/mosaic:0.0.1" as m

#show: m.setup

#let slide-grid = m.grid.h(
  m.grid.cell("left"),
  m.grid.cell("right"),
)

#let slide-progress(left-body, right-body) = m.slide(
  grid: slide-grid,
  cell-styles: (
    left: (align: center + horizon, text: (size: 2em, weight: "bold")),
    right: (
      fill: luma(94%),
      align: center + horizon,
      text: (size: 2em, weight: "bold"),
    ),
  ),
  foreground: place(
    bottom + left,
    block(width: 100%)[
      #m.components.progress(
        variant: "line",
        color: black,
        track: white,
        thickness: 8pt,
      )
    ],
  ),
  ..(left-body, right-body),
)

#slide-progress()[1a][1b]
#slide-progress()[2a][2b]
#slide-progress()[3a][3b]

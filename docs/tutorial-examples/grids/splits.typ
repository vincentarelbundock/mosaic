#import "@local/mosaic:0.0.1" as m

#show: m.setup
#set text(size: 22pt)

#let grid = m.grid.h(
  gutter: 0.7em,
  m.grid.cell("main"),
  m.grid.v(
    gutter: 0.7em,
    m.grid.cell("details"),
    m.grid.cell("notes"),
  ),
)

#m.slide(
  grid: grid,
  cell-styles: (
    main: (align: center + horizon, fill: rgb("#dbeafe")),
    details: (align: center + horizon, fill: rgb("#dcfce7")),
    notes: (align: center + horizon, fill: rgb("#fef3c7")),
  ),
)[
  *Main*
][
  *Details*
][
  *Notes*
]

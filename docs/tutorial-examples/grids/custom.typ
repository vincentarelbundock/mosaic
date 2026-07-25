#import "@local/mosaic:0.0.1" as m

#show: m.setup
#set text(size: 22pt)

// A thin, centered title sits above two uneven columns.
// Each lower column is split into rows with different proportions.
#let colors = m.color.palette("okabe-ito")
#let panel(id) = m.grid.cell(id)
#let grid = m.grid.v(
  m.grid.t(auto, panel("title")),
  m.grid.h(
    m.grid.t(2fr, m.grid.v(
      panel("left-top"),
      m.grid.t(2fr, panel("left-bottom")),
    )),
    m.grid.v(
      m.grid.t(2fr, panel("right-top")),
      panel("right-bottom"),
    ),
  ),
)

#m.slide(grid, cell-styles: (
  title: (fill: colors.at(0), align: center),
  left-top: (fill: colors.at(1)),
  left-bottom: (fill: colors.at(2)),
  right-top: (fill: colors.at(3)),
  right-bottom: (fill: colors.at(4)),
))[
  0
][
  1
][
  2
][
  3
][
  4
]

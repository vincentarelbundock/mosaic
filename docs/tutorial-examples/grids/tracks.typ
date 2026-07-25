#import "@local/mosaic:0.0.1" as m

#show: m.setup
#set text(size: 22pt)

#let colors = (
  rgb("#f8dce5"),
  rgb("#dceafa"),
  rgb("#dff3e8"),
)
#let panel(id) = m.grid.cell(id)
#let panel-style(index) = (
  align: center + horizon,
  stroke: 1pt + white,
  text: (size: 1.5em, weight: "bold"),
  fill: colors.at(index),
)

#m.slide(
  m.grid.h(m.grid.t(2fr, panel("a")), panel("b")),
  cell-styles: (a: panel-style(0), b: panel-style(1)),
)[a][b]

#m.slide(
  m.grid.v(m.grid.t(25%, panel("a")), panel("b")),
  cell-styles: (a: panel-style(0), b: panel-style(1)),
)[a][b]

#m.slide(
  m.grid.h(
    m.grid.t(1fr, panel("a")),
    m.grid.t(2fr, panel("b")),
    m.grid.t(1fr, panel("c")),
  ),
  cell-styles: (a: panel-style(0), b: panel-style(1), c: panel-style(2)),
)[a][b][c]

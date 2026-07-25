#import "@local/mosaic:0.0.1" as m

#show: m.setup
#set text(size: 22pt)
#let panel(id) = m.grid.cell(id)
#let panel-style = (
  align: center + horizon,
  stroke: 1pt + black,
  text: (size: 1.5em, weight: "bold"),
)

// Slide 1

#let columns = m.grid.h(panel("a"), panel("b"), panel("c"))
#m.slide(columns, cell-styles: (a: panel-style, b: panel-style, c: panel-style))[a][b][c]

// Slide 2

#m.slide(
  m.grid.v(panel("a"), panel("b")),
  cell-styles: (a: panel-style, b: panel-style),
)[a][b]

// Slide 3

#m.slide(m.grid.v(
  panel("a"),
  m.grid.h(panel("b"), panel("c")),
  panel("d"),
), cell-styles: (
  a: panel-style,
  b: panel-style,
  c: panel-style,
  d: panel-style,
))[a][b][c][d]

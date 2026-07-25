#import "@local/mosaic:0.0.1" as m

#show: m.setup
#set text(size: 22pt)

#let colors = (
  rgb("#f8dce5"),
  rgb("#dceafa"),
  rgb("#dff3e8"),
  rgb("#fef3c7"),
)
#let panel(id) = m.grid.cell(id)
#let panel-style(index) = (
  align: center + horizon,
  stroke: 1pt + white,
  text: (size: 1.5em, weight: "bold"),
  fill: colors.at(calc.rem(index, colors.len())),
)

#m.slide(
  m.grid.h(panel("a"), panel("b"), panel("c")),
  cell-styles: (a: panel-style(0), b: panel-style(1), c: panel-style(2)),
)[a][b][c]

#m.slide(
  m.grid.v(panel("a"), panel("b"), panel("c")),
  cell-styles: (a: panel-style(0), b: panel-style(1), c: panel-style(2)),
)[a][b][c]

#m.slide(m.grid.h(
  panel("a"),
  m.grid.v(panel("b"), panel("c")),
), cell-styles: (a: panel-style(0), b: panel-style(1), c: panel-style(2)))[a][b][c]

#m.slide(m.grid.v(
  m.grid.h(panel("a"), panel("b")),
  m.grid.h(panel("c"), panel("d")),
), cell-styles: (
  a: panel-style(0),
  b: panel-style(1),
  c: panel-style(2),
  d: panel-style(3),
))[a][b][c][d]

#m.slide(
  m.grid.v(
    panel("title"),
    m.grid.h(
      m.grid.v(panel("col0"), panel("sidebar-note")),
      m.grid.v(
        m.grid.h(panel("col1"), panel("col2")),
        m.grid.h(
          panel("chart"),
          m.grid.v(panel("legend"), panel("annotation")),
        ),
      ),
    ),
    m.grid.h(panel("footer"), panel("status"), panel("page")),
  ),
  cell-styles: (
    title: panel-style(0),
    col0: panel-style(1),
    sidebar-note: panel-style(2),
    col1: panel-style(3),
    col2: panel-style(4),
    chart: panel-style(5),
    legend: panel-style(6),
    annotation: panel-style(7),
    footer: panel-style(8),
    status: panel-style(9),
    page: panel-style(10),
  ),
)[title][col0][sidebar-note][col1][col2][chart][legend][annotation][footer][status][page]

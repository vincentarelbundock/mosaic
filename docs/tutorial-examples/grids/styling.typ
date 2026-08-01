#import "@local/mosaic:0.0.1" as m
#show: m.setup

#let colors = m.color.palette("okabe-ito", lighten: 85%)

// Cells are structural. Style one by targeting its <mosaic-cell-ID> label
// with ordinary Typst rules: set align, then paint the cell block.
#let panel(id, color) = it => {
  show label("mosaic-cell-" + id): set align(right + bottom)
  show label("mosaic-cell-" + id): body => block(
    width: 100%,
    height: 100%,
    fill: color,
    body,
  )
  it
}

#show: panel("a", colors.at(5))
#show: panel("b", colors.at(4))

#m.slide(
  m.grid.h(
    m.grid.cell("a"),
    m.grid.cell("b"),
  ),
)[
  #lorem(18)
][
  #lorem(18)
]

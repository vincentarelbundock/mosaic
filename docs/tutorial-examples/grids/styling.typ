#import "@local/mosaic:0.0.1" as m
#show: m.setup

#let colors = m.color.palette("okabe-ito", lighten: 85%)

#m.slide(
  m.grid.h(
    m.grid.cell("a"),
    m.grid.cell("b"),
  ),
  cell-styles: (
    a: (align: right + bottom, fill: colors.at(5)),
    b: (align: right + bottom, fill: colors.at(4)),
  ),
)[
  #lorem(18)
][
  #lorem(18)
]

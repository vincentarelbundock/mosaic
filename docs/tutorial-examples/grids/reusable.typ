#import "@local/mosaic:0.0.1" as m
#show: m.setup

#let colors = m.color.palette("okabe-ito", lighten: 85%)
#let two-columns = m.grid.h(
  m.grid.cell("a"),
  m.grid.cell("b"),
)
#let two-column-styles = (
  a: (fill: colors.at(5)),
  b: (fill: colors.at(4)),
)

#m.slide(two-columns, cell-styles: two-column-styles)[
  *slide 0 cell 0*
][
  *slide 0 cell 1*
]

#m.slide(two-columns, cell-styles: two-column-styles)[
  *slide 1 cell 0*
][
  *slide 1 cell 1*
]

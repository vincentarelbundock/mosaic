#import "@local/mosaic:0.0.1" as m

#let panel(id) = m.grid.cell(id)
#let grid = m.grid.h(
  ..m.reveal(
    before: "removed",
    after: "visible",
    panel("first"),
    panel("second"),
    panel("third"),
  ),
)

#show: m.setup
#set text(size: 22pt)

#m.slide(grid, cell-styles: (
  first: (inset: 1.5em, fill: blue.lighten(92%)),
  second: (inset: 1.5em, fill: green.lighten(92%)),
  third: (inset: 1.5em, fill: orange.lighten(88%)),
))[
  *Cell 1*

  Initially fills the row.
][
  *Cell 2*

  Joins on step 2.
][
  *Cell 3*

  Joins on step 3.
]

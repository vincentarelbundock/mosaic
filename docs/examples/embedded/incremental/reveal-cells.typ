#import "@local/mosaic:0.0.1" as m

#let grid = m.grids.h(
  ..m.steps.reveal(
    before: "removed",
    after: "visible",
    m.grids.cell("first", inset: 1.5em),
    m.grids.cell("second", inset: 1.5em),
    m.grids.cell("third", inset: 1.5em),
  ),
)

#show: m.setup
#set text(size: 22pt)

// Fill each revealed cell through its stable <mosaic-cell-ID> label.
#let fill(id, color) = it => {
  show label("mosaic-cell-" + id): body => block(
    width: 100%,
    height: 100%,
    fill: color,
    body,
  )
  it
}
#show: fill("first", blue.lighten(92%))
#show: fill("second", green.lighten(92%))
#show: fill("third", orange.lighten(88%))

#m.slide(layout: grid)[
  *Cell 1*

  Initially fills the row.
][
  *Cell 2*

  Joins on step 2.
][
  *Cell 3*

  Joins on step 3.
]

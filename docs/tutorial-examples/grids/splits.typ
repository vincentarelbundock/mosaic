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

// Fill and center each panel through its stable <mosaic-cell-ID> label.
#let panel(id, color) = it => {
  show label("mosaic-cell-" + id): set align(center + horizon)
  show label("mosaic-cell-" + id): body => block(
    width: 100%,
    height: 100%,
    fill: color,
    body,
  )
  it
}

#show: panel("main", rgb("#dbeafe"))
#show: panel("details", rgb("#dcfce7"))
#show: panel("notes", rgb("#fef3c7"))

#m.slide(grid: grid)[
  *Main*
][
  *Details*
][
  *Notes*
]

#import "@local/mosaic:0.0.1" as m

#show: m.setup
#set text(size: 22pt)

// Cells are structural. Give each panel a shared look by targeting its stable
// <mosaic-cell-ID> label with ordinary Typst rules.
#let panel(id) = it => {
  show label("mosaic-cell-" + id): set align(center + horizon)
  show label("mosaic-cell-" + id): set text(size: 1.5em, weight: "bold")
  show label("mosaic-cell-" + id): m.surface(stroke: 1pt + black)
  it
}

#show: panel("a")
#show: panel("b")
#show: panel("c")
#show: panel("d")

// Slide 1

#m.slide(layout: m.grid.h("a", "b", "c"))[a][b][c]

// Slide 2

#m.slide(layout: m.grid.v("a", "b"))[a][b]

// Slide 3

#m.slide(layout: m.grid.v(
  "a",
  m.grid.h("b", "c"),
  "d",
))[a][b][c][d]

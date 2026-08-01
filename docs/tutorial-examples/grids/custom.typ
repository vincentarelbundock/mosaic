#import "@local/mosaic:0.0.1" as m

#show: m.setup
#set text(size: 22pt)

// A thin, centered title sits above two uneven columns.
// Each lower column is split into rows with different proportions.
#let colors = m.color.palette("okabe-ito")
#let grid = m.grid.v(
  m.grid.t(auto, "title"),
  m.grid.h(
    m.grid.t(2fr, m.grid.v(
      "left-top",
      m.grid.t(2fr, "left-bottom"),
    )),
    m.grid.v(
      m.grid.t(2fr, "right-top"),
      "right-bottom",
    ),
  ),
)

// Fill each panel through its stable <mosaic-cell-ID> label. Cells are
// structural, so filling one is an ordinary Typst show rule. The full-height
// panels ask for `height: 100%`; the auto-sized title hugs its content.
#let fill(id, color, height: 100%) = it => {
  show label("mosaic-cell-" + id): body => block(
    width: 100%,
    height: height,
    fill: color,
    body,
  )
  it
}

#show: fill("title", colors.at(0), height: auto)
#show: fill("left-top", colors.at(1))
#show: fill("left-bottom", colors.at(2))
#show: fill("right-top", colors.at(3))
#show: fill("right-bottom", colors.at(4))
#show label("mosaic-cell-title"): set align(center)

#m.slide(grid)[0][1][2][3][4]

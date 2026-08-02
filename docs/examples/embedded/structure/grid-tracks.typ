#import "@local/mosaic:0.0.1" as m

#show: m.setup
#set text(size: 22pt)

#let colors = (
  rgb("#f8dce5"),
  rgb("#dceafa"),
  rgb("#dff3e8"),
)

// Colour each panel through its stable <mosaic-cell-ID> label. Cells are
// structural, so every visual choice is an ordinary Typst rule.
#let panels(fills, body) = {
  let out = body
  for (id, fill) in fills {
    out = {
      show label("mosaic-cell-" + id): set align(center + horizon)
      show label("mosaic-cell-" + id): set text(size: 1.5em, weight: "bold")
      show label("mosaic-cell-" + id): it => block(
        width: 100%,
        height: 100%,
        fill: fill,
        stroke: 1pt + white,
        it,
      )
      out
    }
  }
  out
}

#panels((a: colors.at(0), b: colors.at(1)))[
  #m.slide(m.grid.h(m.grid.t(2fr, "a"), "b"))[a][b]
]

#panels((a: colors.at(0), b: colors.at(1)))[
  #m.slide(m.grid.v(m.grid.t(25%, "a"), "b"))[a][b]
]

#panels((a: colors.at(0), b: colors.at(1), c: colors.at(2)))[
  #m.slide(
    m.grid.h(
      m.grid.t(1fr, "a"),
      m.grid.t(2fr, "b"),
      m.grid.t(1fr, "c"),
    ),
  )[a][b][c]
]

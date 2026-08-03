#import "@local/mosaic:0.0.1" as m

#show: m.setup
#set text(size: 22pt)

#let colors = (
  rgb("#f8dce5"),
  rgb("#dceafa"),
  rgb("#dff3e8"),
  rgb("#fef3c7"),
)

// Colour each panel through its stable <mosaic-cell-ID> label. Cells are
// structural, so every visual choice is an ordinary Typst rule.
#let panels(ids, body) = {
  let out = body
  for (index, id) in ids.enumerate() {
    let fill = colors.at(calc.rem(index, colors.len()))
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

#panels(("a", "b", "c"))[
  #m.slide(layout: m.grid.h("a", "b", "c"))[a][b][c]
]

#panels(("a", "b", "c"))[
  #m.slide(layout: m.grid.v("a", "b", "c"))[a][b][c]
]

#panels(("a", "b", "c"))[
  #m.slide(layout: m.grid.h("a", m.grid.v("b", "c")))[a][b][c]
]

#panels(("a", "b", "c", "d"))[
  #m.slide(layout: m.grid.v(
    m.grid.h("a", "b"),
    m.grid.h("c", "d"),
  ))[a][b][c][d]
]

#panels((
  "title", "col0", "sidebar-note", "col1", "col2", "chart",
  "legend", "annotation", "footer", "status", "page",
))[
  #m.slide(layout: 
    m.grid.v(
      "title",
      m.grid.h(
        m.grid.v("col0", "sidebar-note"),
        m.grid.v(
          m.grid.h("col1", "col2"),
          m.grid.h(
            "chart",
            m.grid.v("legend", "annotation"),
          ),
        ),
      ),
      m.grid.h("footer", "status", "page"),
    ),
  )[title][col0][sidebar-note][col1][col2][chart][legend][annotation][footer][status][page]
]

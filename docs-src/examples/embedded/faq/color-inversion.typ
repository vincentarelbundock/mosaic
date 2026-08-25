#import "@preview/mosaic:0.0.1" as m
#show: m.setup

// A fill and the text that reads against it are one decision, so bind each
// pair once. Mosaic derives neither half from the other.
#let paper = (fill: rgb("#f4f0e8"), text: rgb("#20262d"))
#let ink = (fill: rgb("#20262d"), text: rgb("#f4f0e8"))

// Paint the named cells with a pair: `m.surface` fills the cell's own block,
// and the `set text` rule beside it colors the content inside.
#let painted(pair, ..ids) = body => {
  let out = body
  for id in ids.pos() {
    let cell = label("mosaic-cell-" + id)
    out = {
      show cell: set text(fill: pair.text)
      show cell: m.surface(fill: pair.fill, height: 100%)
      out
    }
  }
  out
}

#let split = m.grids.columns(
  m.grids.track(0.44fr, m.grids.cell("headline", inset: 1.5em)),
  m.grids.track(0.56fr, m.grids.cell("copy", inset: 1.5em)),
)

#let panel(pair, name) = [
  #show: painted(pair, "headline", "copy")
  #m.slide(layout: split, cells: (
    headline: [
      #set align(left + horizon)
      #text(size: 1.6em, weight: "bold")[On #name]
    ],
    copy: [
      #set align(left + horizon)
      One layout, one pair of colors. The same rule that fills the cell also
      sets the fill of the text inside it, so the two never drift apart.
    ],
  ))
]

#panel(paper, "paper")
#panel(ink, "ink")

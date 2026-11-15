#import "@local/mosaic:0.0.3" as mosaic
#import "../mosaic/src/grid/content.typ": resolve-content

// A slide's opening heading is its header, whichever way the slide is
// written. An automatic `==` slide, `slide[== T][B]`, and `slide` with the
// heading and the body in one block resolve to the same header and body
// cells; pages 1 to 3 must lay those cells out identically.
#let grid = mosaic.grids.rows(tracks: (auto, 1fr, auto), "header", "body", "footer")
#let defaults = (header: none, footer: [Deck footer])
#let resolve(..bodies) = resolve-content(grid, (:), bodies.pos(), defaults: defaults)

#assert(
  resolve[== T][B] == (header: [== T], footer: [Deck footer], body: [B]),
  message: repr(resolve[== T][B]),
)
// The heading alone, or the heading before body text in the same block.
#assert(resolve[== T].header == [== T])
#assert(resolve[== T].body == [])
#let joined = resolve[
  == T

  B
]
#assert(joined.header == [== T])
#assert(joined.body == [B], message: repr(joined.body))
// A body that does not open with a heading fills the first cell, and the
// count never changes that.
#assert(resolve[A].body == [A])
#assert(resolve[A].header == [])
#assert(resolve[Lead-in == Late].header == [])
// A constructed heading and one inside a styled block open a slide too.
#assert(resolve(heading(level: 2)[T])[B].header.depth == 2)
#let styled = resolve[
  #[
    #set text(style: "italic")
    == T
  ]
][B]
#assert(styled.header != [] and styled.body == [B])
// No `header` cell: nothing is lifted.
#assert(
  resolve-content(mosaic.grids.columns("left", "right"), (:), ([== T], [B]))
    == (left: [== T], right: [B]),
)

#show: mosaic.setup.with(
  paper: (width: 240pt, height: 135pt),
  spacing: (inset: 6pt),
  cells: (footer: [Deck footer]),
  layouts: (content: mosaic.layouts.content(variant: "header-body-footer")),
)
#set text(size: 7pt)

== Opening heading

Body text.

#mosaic.slide[== Opening heading][Body text.]

#mosaic.slide[
  == Opening heading

  Body text.
]

// The heading keeps the steps after it in the body: the header is stable
// across both frames, as on an automatic slide.
#mosaic.slide[
  == Stable heading
  First. #mosaic.steps.pause Second.
]

#context {
  assert(counter(page).final().first() == 5)
  assert(query(heading).len() == 4)
  for anchor in (
    "header-top-left", "header-bottom-right", "body-top-left",
    "body-bottom-right", "footer-top-left",
  ) {
    let positions = query(label("mosaic-cell-" + anchor)).map(
      item => item.location().position(),
    )
    assert(positions.len() == 5, message: anchor + ": " + repr(positions))
    let first = positions.first()
    assert(
      positions.all(position => position.x == first.x and position.y == first.y),
      message: anchor + ": " + repr(positions),
    )
  }
  // The headings sit inside the header cell, above the body, on every slide.
  let body-top = query(<mosaic-cell-body-top>).first().location().position().y
  assert(query(heading).all(it => it.location().position().y < body-top))
}

#import "@local/mosaic:0.0.3" as mosaic
#import "../mosaic/src/grid/content.typ": resolve-content

// Positional bodies are routed by their count alone, never by their content.
// A slide gives one body per fillable cell without a deck default, or one per
// fillable cell; a cell named `footer` is never fillable and is reached by
// name. Every other count is an error (the tests/invalid/slide-bodies-*
// fixtures), except zero.

// The routing itself, with the defaults a deck supplies: setup always injects
// a `header` default, and this deck adds a footer.
#let defaults = (header: none, footer: [Deck footer])
#let route(grid, ..bodies) = resolve-content(grid, (:), bodies.pos(), defaults: defaults)
#let header-body = mosaic.grids.rows("header", "body")
#let two-columns = mosaic.grids.rows("header", mosaic.grids.columns("body-1", "body-2"))
#let with-footer = mosaic.grids.rows("header", "body", "footer")

#assert(route(header-body)[A] == (header: [], body: [A]))
#assert(route(header-body)[A][B] == (header: [A], body: [B]))
// Content is not read: a lone heading goes to the body like any other body.
#assert(route(header-body)[== Title] == (header: [], body: [== Title]))
#assert(route(two-columns)[L][R] == (header: [], body-1: [L], body-2: [R]))
#assert(route(two-columns)[H][L][R] == (header: [H], body-1: [L], body-2: [R]))
#assert(route(with-footer)[A] == (header: [], footer: [Deck footer], body: [A]))
#assert(
  route(with-footer)[H][B] == (header: [H], footer: [Deck footer], body: [B]),
)
// Zero bodies is an empty slide.
#assert(route(header-body) == (header: [], body: []))

// The same placements rendered. Each body carries a probe naming the cell it
// must land in; the check below finds that cell on the probe's page.
#show: mosaic.setup.with(
  paper: (width: 240pt, height: 135pt),
  spacing: (inset: 6pt),
  cells: (footer: [Deck footer]),
)
#set text(size: 7pt)

#let probe(cell) = [#metadata(cell) <probe>]
#let content(..fields) = mosaic.layouts.content(..fields)

// 1: header-body, one body.
#mosaic.slide(layout: content(variant: "header-body"))[Only #probe("body")]
// 2: header-body, two bodies.
#mosaic.slide(layout: content(variant: "header-body"))[
  == Title #probe("header")
][Body #probe("body")]
// 3: two columns, two bodies.
#mosaic.slide(layout: content(variant: "header-body", columns: 2))[
  Left #probe("body-1")
][Right #probe("body-2")]
// 4: two columns, three bodies.
#mosaic.slide(layout: content(variant: "header-body", columns: 2))[
  == Title #probe("header")
][Left #probe("body-1")][Right #probe("body-2")]
// 5: header-body-footer, one body; the deck footer stays.
#mosaic.slide(layout: content(variant: "header-body-footer"))[
  Only #probe("body")
]
// 6: header-body-footer, two bodies.
#mosaic.slide(layout: content(variant: "header-body-footer"))[
  == Title #probe("header")
][Body #probe("body")]
// 7: the footer by name.
#mosaic.slide(layout: content(variant: "header-body-footer"), cells: (
  header: [== Title #probe("header")],
  body: [Body #probe("body")],
  footer: [Slide footer #probe("footer")],
))
// 8: no bodies at all.
#mosaic.slide(layout: content(variant: "header-body-footer"))

#context {
  assert(counter(page).final().first() == 8)
  let probes = query(<probe>)
  assert(probes.len() == 14, message: repr(probes.len()))
  for probe in probes {
    let at = probe.location().position()
    let edge(name) = query(label("mosaic-cell-" + probe.value + "-" + name))
      .map(it => it.location().position())
      .find(position => position.page == at.page)
    let (top, bottom) = (edge("top-left"), edge("bottom-right"))
    assert(
      top != none and top.x <= at.x and at.x <= bottom.x
        and top.y <= at.y and at.y <= bottom.y,
      message: probe.value + " on page " + str(at.page) + ": " + repr((at, top, bottom)),
    )
  }
}

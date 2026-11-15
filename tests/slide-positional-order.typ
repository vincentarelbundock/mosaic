#import "@local/mosaic:0.0.3" as mosaic
#import "../mosaic/src/grid/content.typ": resolve-content

// Positional bodies fill the layout's cells in depth-first order, starting
// with the first: the header, the footer, and cells with a deck default all
// count, and a body's content is never read. Fewer bodies than cells leaves
// the trailing cells to their deck default, or empty; more is an error
// (tests/invalid/too-many.typ and slide-bodies-*); none is an empty slide. A
// cell named in `cells:` leaves the pool, and the bodies fill what remains.

// The routing itself, with the defaults a deck supplies: setup always injects
// an empty `header` default, and this deck adds a footer.
#let defaults = (header: none, footer: [Deck footer])
#let route(grid, named: (:), ..bodies) = resolve-content(
  grid, named, bodies.pos(), defaults: defaults,
)
#let header-body = mosaic.grids.rows("header", "body")
#let two-columns = mosaic.grids.rows("header", mosaic.grids.columns("body-1", "body-2"))
#let with-footer = mosaic.grids.rows("header", "body", "footer")

#assert(route(header-body)[A] == (header: [A], body: []))
#assert(route(header-body)[][B] == (header: [], body: [B]))
#assert(route(header-body)[A][B] == (header: [A], body: [B]))
#assert(route(two-columns)[H][L] == (header: [H], body-1: [L], body-2: []))
#assert(route(two-columns)[H][L][R] == (header: [H], body-1: [L], body-2: [R]))
// The deck footer default holds when the bodies stop before it, and a third
// body reaches it.
#assert(route(with-footer)[A] == (header: [A], footer: [Deck footer], body: []))
#assert(route(with-footer)[H][B] == (header: [H], footer: [Deck footer], body: [B]))
#assert(route(with-footer)[H][B][F] == (header: [H], footer: [F], body: [B]))
// Zero bodies is an empty slide.
#assert(route(header-body) == (header: [], body: []))
// `cells:` takes its cells out of the pool; the bodies fill the rest in order.
#assert(
  route(with-footer, named: (header: [T]))[B][F]
    == (header: [T], footer: [F], body: [B]),
)
#assert(
  route(two-columns, named: (body-1: [L]))[H][R]
    == (header: [H], body-1: [L], body-2: [R]),
)

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

// 0: an automatic heading slide, which names its cells and so is untouched
// by positional order: the heading in the header, the text in the body.
== Automatic #probe("header")

Body #probe("body")

// 1: header-body, one body: the header.
#mosaic.slide(layout: content(variant: "header-body"))[Only #probe("header")]
// 2: header-body, two bodies.
#mosaic.slide(layout: content(variant: "header-body"))[
  == Title #probe("header")
][Body #probe("body")]
// 3: two columns, two bodies: the second column stays empty.
#mosaic.slide(layout: content(variant: "header-body", columns: 2))[
  == Title #probe("header")
][Left #probe("body-1")]
// 4: two columns, three bodies.
#mosaic.slide(layout: content(variant: "header-body", columns: 2))[
  == Title #probe("header")
][Left #probe("body-1")][Right #probe("body-2")]
// 5: header-body-footer, one body; the deck footer stays.
#mosaic.slide(layout: content(variant: "header-body-footer"))[
  == Title #probe("header")
]
// 6: header-body-footer, two bodies; the deck footer stays.
#mosaic.slide(layout: content(variant: "header-body-footer"))[
  == Title #probe("header")
][Body #probe("body")]
// 7: header-body-footer, three bodies: the third replaces the deck footer.
#mosaic.slide(layout: content(variant: "header-body-footer"))[
  == Title #probe("header")
][Body #probe("body")][Source #probe("footer")]
// 8: the header by name, then body and footer positionally.
#mosaic.slide(
  layout: content(variant: "header-body-footer"),
  cells: (header: [== Named #probe("header")]),
)[Body #probe("body")][Source #probe("footer")]
// 9: no bodies at all.
#mosaic.slide(layout: content(variant: "header-body-footer"))

#context {
  assert(counter(page).final().first() == 10)
  let probes = query(<probe>)
  assert(probes.len() == 19, message: repr(probes.len()))
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

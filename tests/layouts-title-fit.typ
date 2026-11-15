// A long title over a long author list must never overprint. The details cap
// themselves first, and the heading stack then scales into the room they
// leave, in every variant. scripts/run-tests.py reads the word boxes of this
// fixture and requires the last title word (ZQLAST) to end above the first
// author (ZQAUTHOR) on each page where the byline sits beneath the heading.
#import "@local/mosaic:0.0.3" as mosaic

#let authors = range(8).map(index => mosaic.layouts.author(
  if index == 0 [ZQAUTHOR Zero] else [Author Number #str(index)],
  affiliations: ([University #str(calc.rem(index, 3))],),
  email: "author" + str(index) + "@example.org",
))

#show: mosaic.setup.with(
  title: [A rather long title that wraps over several lines to test the collision behaviour of each variant in ZQLAST],
  subtitle: [A subtitle that is also long enough to wrap onto a second line of its own],
  authors: authors,
  date: [2026],
)

#mosaic.slide(layout: "title", variant: "centered")
#mosaic.slide(layout: "title", variant: "bordered")
#mosaic.slide(layout: "title", variant: "ruled")
#mosaic.slide(layout: "title", variant: "kicker")
#mosaic.slide(layout: "title", variant: "academic")
#mosaic.slide(layout: "title", variant: "panel")

// `centered` is the plain composition: its short accent rule draws on request.
#mosaic.slide(layout: "title", variant: "centered", rule: true, accent: rgb("#13579b"))

// A panel with no authors and no date has nothing to carry, so the heading
// takes the slide and no details cell is drawn.
#import "../mosaic/src/layout/resolver.typ": resolve-layout
#import "../mosaic/src/settings.typ": make-settings
#import "support/grid.typ" as grid-test
#let bare-panel = resolve-layout(
  mosaic.layouts.title(title: [Bare], variant: "panel", authors: (), date: none),
  make-settings(),
)
#assert(grid-test.cell-ids(bare-panel) == ("title",))
#let full-panel = resolve-layout(
  mosaic.layouts.title(title: [Full], variant: "panel", authors: [Ada], date: none),
  make-settings(),
)
#assert(grid-test.cell-ids(full-panel) == ("details", "title"))

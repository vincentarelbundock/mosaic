// Where a picture sits, in each layout that carries one. The title layout's
// `image` variant reads `position`; the section and image layouts name the
// place through their variants. The same five places exist in all three.
// scripts/run-tests.py reads the pages this fixture renders.
#import "@local/mosaic:0.0.3" as mosaic
#import "../mosaic/src/layout/resolver.typ": resolve-layout
#import "../mosaic/src/settings.typ": make-settings
#import "support/grid.typ" as grid-test

#let river = path("/docs-src/assets/images/title-river.webp")
#let dog = path("/docs-src/assets/images/dog.webp")
#let settings = make-settings(deck: (title: [Deck], authors: [Ada]))
#let cells(layout) = grid-test.cell-ids(resolve-layout(layout, settings))

// The directional places split the slide, picture first on the left and top;
// the background place composes one cell with the picture behind it.
#for (position, expected) in (
  left: ("image", "title"),
  top: ("image", "title"),
  right: ("title", "image"),
  bottom: ("title", "image"),
  background: ("title",),
) {
  assert(cells(mosaic.layouts.title(variant: "image", position: position, image: river)) == expected)
  let section = expected.map(id => if id == "title" { "section" } else { id })
  assert(cells(mosaic.layouts.section(variant: "image-" + position, image: dog)) == section)
}
// `auto` is the left position of the title's image variant.
#assert(cells(mosaic.layouts.title(variant: "image", image: river)) == ("image", "title"))
#assert(cells(mosaic.layouts.image(dog)) == ("header", "image"))
#assert(cells(mosaic.layouts.image(dog, variant: "figure")) == ("header", "image"))
#assert(cells(mosaic.layouts.image(dog, variant: "left")) == ("image", "header", "body"))
#assert(cells(mosaic.layouts.image(dog, variant: "bottom")) == ("header", "body", "image"))
#assert(cells(mosaic.layouts.image(dog, variant: "full")) == ("body",))
// `position` is the title's field alone.
#assert("position" not in mosaic.layouts.image(dog).fields)
#assert("position" not in mosaic.layouts.section().fields)

#show: mosaic.setup.with(
  title: [ZQDECK title],
  subtitle: [ZQSUB subtitle],
  authors: ([ZQAUTHOR One], [Author Two]),
  date: [ZQDATE],
  overflow: "error",
)

// Page 1: the title stack over a full-slide picture, recolored by one rule.
#[
  #show label("mosaic-cell-title"): set text(fill: rgb("#fedcba"))
  #mosaic.slide(
    layout: "title",
    variant: "image",
    position: "background",
    image: mosaic.components.image(river, scrim: black.transparentize(45%)),
  )
]

// Pages 2 to 5: `none` suppresses any inherited field, the title and the
// authors included, and the slide still composes.
#mosaic.slide(layout: "title", title: none)
#mosaic.slide(layout: "title", variant: "bordered", authors: none)
#mosaic.slide(layout: "title", variant: "centered", title: none, subtitle: none, authors: none, date: none)
#mosaic.slide(layout: "title", variant: "image", position: "right", image: river, title: none, subtitle: none, authors: none, date: none)

// Pages 6 and 7: the panel's accent rule is its mark, so `rule: false`
// removes it and an explicit accent colors it.
#mosaic.slide(layout: "title", variant: "panel", accent: rgb("#13579b"))
#mosaic.slide(layout: "title", variant: "panel", accent: rgb("#13579b"), rule: false)

// Page 8: an explicit accent colors the baseline number and its hairline, so
// the deck's semantic accent no longer appears on the slide.
#mosaic.slide(
  layout: mosaic.layouts.section(variant: "baseline", accent: rgb("#a1b2c3")),
)[Baseline]

// Pages 9 to 12: `<mosaic-section-title>` labels the visible title text in
// every variant, whether the body is a heading or plain content.
#[
  #show label("mosaic-section-title"): set text(fill: rgb("#12ab34"))
  #mosaic.slide(layout: mosaic.layouts.section(variant: "plain", subtitle: [Sub]))[Plain]
  #mosaic.slide(layout: mosaic.layouts.section(variant: "rule"))[= Rule heading]
  #mosaic.slide(layout: mosaic.layouts.section(variant: "toc"))[Toc]
  #mosaic.slide(layout: mosaic.layouts.section(variant: "image-top", image: dog))[Image]
]

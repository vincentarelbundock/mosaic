// Where a picture sits, in each layout that carries one. Every layout names
// the place through its variant: the title and section layouts share five
// `image-*` variants, and the image layout has `full` and the four sides.
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
  assert(cells(mosaic.layouts.title(variant: "image-" + position, image: river)) == expected)
  let section = expected.map(id => if id == "title" { "section" } else { id })
  assert(cells(mosaic.layouts.section(variant: "image-" + position, image: dog)) == section)
}
#assert(cells(mosaic.layouts.image(dog)) == ("header", "image"))
#assert(cells(mosaic.layouts.image(dog, variant: "figure")) == ("header", "image"))
#assert(cells(mosaic.layouts.image(dog, variant: "left")) == ("image", "header", "body"))
#assert(cells(mosaic.layouts.image(dog, variant: "bottom")) == ("header", "body", "image"))
#assert(cells(mosaic.layouts.image(dog, variant: "full")) == ("body",))
// No layout has a `position` field.
#assert("position" not in mosaic.layouts.image(dog).fields)
#assert("position" not in mosaic.layouts.section().fields)
#assert("position" not in mosaic.layouts.title().fields)

// A picture dictionary and the equivalent `components.image(..)` build the
// same element, so the two spellings render the same slide.
#let scrim = black.transparentize(45%)
#let as-dictionary = (path: river, alt: "Wetlands", scrim: scrim)
#let as-content = mosaic.components.image(river, alt: "Wetlands", scrim: scrim)
// Compared through `repr`, which prints every field of the element: two
// image elements never compare equal as values, even when identical.
#let background(layout) = repr(grid-test.info(
  resolve-layout(layout, settings),
  layout.name,
).cell.style.background)
#let image-cell(layout) = grid-test.info(resolve-layout(layout, settings), "image").cell.content
#let picture(layout) = repr(image-cell(layout))
#assert(
  background(mosaic.layouts.title(variant: "image-background", image: as-dictionary))
    == background(mosaic.layouts.title(variant: "image-background", image: as-content)),
)
#assert(
  background(mosaic.layouts.section(variant: "image-background", image: as-dictionary))
    == background(mosaic.layouts.section(variant: "image-background", image: as-content)),
)
#assert(
  picture(mosaic.layouts.title(variant: "image-left", image: as-dictionary))
    == picture(mosaic.layouts.title(variant: "image-left", image: as-content)),
)
// (The image layout boxes ready-made content at the region's size and rebuilds
// a dictionary at that size, so there the elements differ and only the
// rendering agrees.)
// A dictionary `fit` key applies, and the layout's explicit `fit:` wins over it.
#assert(image-cell(mosaic.layouts.image((path: dog, fit: "contain"), variant: "left")).fit == "contain")
#assert(
  image-cell(mosaic.layouts.image((path: dog, fit: "cover"), variant: "left", fit: "contain")).fit
    == "contain",
)

#show: mosaic.setup.with(
  title: [ZQDECK title],
  subtitle: [ZQSUB subtitle],
  authors: ([ZQAUTHOR One], [Author Two]),
  date: [ZQDATE],
  overflow: "error",
)

// Page 1: the title stack over a full-slide picture given as a dictionary
// with a scrim, recolored by one rule.
#[
  #show label("mosaic-cell-title"): set text(fill: rgb("#fedcba"))
  #mosaic.slide(
    layout: "title",
    variant: "image-background",
    image: (path: river, scrim: black.transparentize(45%)),
  )
]

// Pages 2 to 5: `none` suppresses any inherited field, the title and the
// authors included, and the slide still composes.
#mosaic.slide(layout: "title", title: none)
#mosaic.slide(layout: "title", variant: "bordered", authors: none)
#mosaic.slide(layout: "title", variant: "centered", title: none, subtitle: none, authors: none, date: none)
#mosaic.slide(layout: "title", variant: "image-right", image: river, title: none, subtitle: none, authors: none, date: none)

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

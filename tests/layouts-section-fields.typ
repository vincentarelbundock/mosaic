// Field behavior of the section layout that a clean compile does not prove;
// scripts/run-tests.py reads the rendered pages.
#import "@local/mosaic:0.0.3" as mosaic
#import "../mosaic/src/layout/resolver.typ": resolve-layout
#import "../mosaic/src/settings.typ": make-settings
#import "support/grid.typ" as grid-test

#let dog = path("/docs-src/assets/images/dog.webp")

#show: mosaic.setup

// Page 1: the plain subtitle is a caption under the title, not a second
// title. Strings are accepted for both optional fields.
#mosaic.slide(
  layout: mosaic.layouts.section(variant: "plain", number: "01", subtitle: "zqsubtitle"),
)[ZQSECTION]

// Pages 2 and 3: an explicit accent recolors the number in the variants that
// used to ignore it.
#mosaic.slide(
  layout: mosaic.layouts.section(variant: "baseline", accent: rgb("#a1b2c3")),
)[Baseline]
#mosaic.slide(
  layout: mosaic.layouts.section(variant: "numeral", accent: rgb("#654321")),
)[Numeral]

// A directional section cell fills its region like the plain one, so a
// `set block(fill: ..)` rule on its label paints the region and not a strip
// around the text.
#for position in ("left", "right", "top", "bottom") {
  let resolved = resolve-layout(
    mosaic.layouts.section(variant: "image", position: position, image: dog),
    make-settings(),
  )
  let style = grid-test.info(resolved, "section").cell.style
  assert(
    not style.at("content-sized", default: false),
    message: position + " section cell must fill its region",
  )
}
#[
  #show label("mosaic-cell-section"): set block(fill: rgb("#fedcba"))
  #mosaic.slide(
    layout: mosaic.layouts.section(variant: "image", position: "left", image: dog),
  )[Recolored]
]

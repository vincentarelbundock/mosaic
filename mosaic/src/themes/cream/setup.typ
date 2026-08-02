#import "../../setup.typ": setup as base-setup
#import "../setup-common.typ": configured-options, normalize-lists
#import "layouts.typ" as layouts
#import "tokens.typ" as tokens

/// Sets up Mosaic with Cream typography, native cell rules, and layouts.
#let setup(body, font: "Inter", base-size: 18pt, ..options) = {
  let configured = configured-options("Cream", layouts, options, defaults: (
    spacing: (inset: 42pt),
  ))

  show: base-setup.with(..configured)
  show: normalize-lists
  set page(fill: tokens.sage)
  set text(font: font, size: base-size, fill: tokens.ink)
  show heading.where(level: 1): set text(size: base-size * 1.9, weight: "bold")
  show heading.where(level: 2): set text(size: base-size * 1.25, weight: "bold")
  show heading: set block(below: 0.5em)
  show label("mosaic-cell-title"): set align(left + horizon)
  show label("mosaic-cell-title"): it => block(
    width: 100%,
    height: 100%,
    fill: tokens.cream,
    text(fill: tokens.ink, it),
  )
  show label("mosaic-cell-section"): set align(left + horizon)
  show label("mosaic-cell-section"): set text(
    size: base-size,
    weight: "regular",
  )
  show label("mosaic-cell-section"): it => block(width: 100%)[
    #it
    #v(0.5em)
    #line(length: 30%, stroke: 1pt + tokens.ink)
  ]
  body
}

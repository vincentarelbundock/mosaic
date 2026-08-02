#import "../../setup.typ": setup as base-setup
#import "../setup-common.typ": configured-options, normalize-lists
#import "layouts.typ" as layouts
#import "tokens.typ" as tokens

/// Sets up Mosaic with Minimalist typography, native cell rules, and layouts.
#let setup(body, font: "Source Serif 4", base-size: 14pt, ..options) = {
  let configured = configured-options("Minimalist", layouts, options, defaults: (
    spacing: (inset: 45pt),
  ))

  show: base-setup.with(..configured)
  show: normalize-lists
  set page(fill: tokens.cream)
  set text(font: font, fill: tokens.red, size: base-size)
  show heading.where(level: 1): set text(size: base-size * 2.2, weight: "bold")
  show heading.where(level: 2): set text(size: base-size * 1.79, weight: "bold")
  show heading: set block(below: 0.6em)
  show label("mosaic-cell-title"): set align(left + horizon)
  show label("mosaic-cell-section"): set text(
    size: base-size,
    weight: "regular",
  )
  body
}

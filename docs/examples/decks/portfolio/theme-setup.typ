#import "@local/mosaic:0.0.1" as mosaic
#import "theme-layouts.typ" as layouts
#import "theme-tokens.typ" as tokens

#let automatic-slide(title, body) = mosaic.slide(
  grid: layouts.default(),
  content: (header: title, body: body),
)

#let setup(body, font: "Inter", base-size: 13pt, ..options) = {
  assert(options.pos().len() == 0, message: "Grayscale setup accepts only its document body positionally")
  let defaults = (
    spacing: (inset: 40pt),
    auto-slide: automatic-slide,
    section-grid: layouts.section(),
  )
  let configured = defaults + options.named()

  show: mosaic.setup.with(..configured)
  set page(fill: tokens.paper)
  set text(font: font, size: base-size, fill: tokens.ink)
  show list.where(tight: true): it => list(tight: false, ..it.children)
  show enum.where(tight: true): it => enum(tight: false, ..it.children)
  set list(spacing: 0.9em)
  set enum(spacing: 0.9em)
  show heading: set text(weight: "bold")
  show label("mosaic-cell-header"): it => block(width: 100%)[
    #it
    #line(length: 100%, stroke: 0.6pt + tokens.gray)
  ]
  show label("mosaic-cell-title"): set align(left + horizon)
  show label("mosaic-cell-title"): it => block(
    width: 100%,
    height: 100%,
    fill: tokens.ink,
    text(fill: white, it),
  )
  show label("mosaic-cell-section"): set align(left + horizon)
  show label("mosaic-cell-section"): it => block(
    width: 100%, height: 100%, fill: tokens.ink, text(fill: white, it),
  )
  show label("mosaic-cell-section-subtitle"): it => block(
    width: 100%, height: 100%, fill: tokens.ink,
    text(fill: tokens.gray, size: 15pt, it),
  )
  show label("mosaic-cell-rest"): it => block(
    width: 100%, height: 100%, fill: tokens.paper, it,
  )
  body
}

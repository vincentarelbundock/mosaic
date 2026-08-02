#import "@local/mosaic:0.0.1" as mosaic
#import "_starter-layouts.typ" as layouts
#import "_starter-tokens.typ" as tokens

#let automatic-slide(title, body) = mosaic.slide(
  grid: layouts.default(),
  content: (header: title, body: body),
)

#let setup(body, base-size: 20pt, ..options) = {
  assert(options.pos().len() == 0, message: "starter setup accepts only its body positionally")
  let configured = (
    features: (slide-number: true),
    auto-slide: automatic-slide,
    section-grid: layouts.section(),
  ) + options.named()
  show: mosaic.setup.with(..configured)
  set page(fill: tokens.mist)
  set text(size: base-size, fill: tokens.navy)
  show list.where(tight: true): it => list(tight: false, ..it.children)
  set list(spacing: 0.9em)
  show label("mosaic-cell-section"): it => block(
    width: 100%, height: 100%, fill: tokens.gold, it,
  )
  body
}

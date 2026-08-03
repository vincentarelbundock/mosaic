// Passive Greyscale definition vendored with this deck.
#import "theme-layouts.typ" as layouts
#import "theme-tokens.typ" as tokens

#let apply(body, colors: (:), options: (:)) = {
  show heading: set text(weight: "bold")
  show label("mosaic-cell-header"): it => block(width: 100%)[
    #it
    #line(length: 100%, stroke: 0.6pt + colors.line)
  ]
  show label("mosaic-cell-title"): set align(left + horizon)
  show label("mosaic-cell-title"): it => block(
    width: 100%, height: 100%, fill: colors.text,
    text(fill: colors.canvas, it),
  )
  show label("mosaic-cell-section"): set align(left + horizon)
  show label("mosaic-cell-section"): it => block(
    width: 100%, height: 100%, fill: colors.text,
    text(fill: colors.canvas, it),
  )
  show label("mosaic-cell-section-subtitle"): it => block(
    width: 100%, height: 100%, fill: colors.text,
    text(fill: colors.muted, size: 15pt, it),
  )
  show label("mosaic-cell-rest"): it => block(
    width: 100%, height: 100%, fill: colors.canvas, it,
  )
  body
}
#let definition = (
  name: "Greyscale",
  colors: tokens.colors,
  defaults: (spacing: (inset: 40pt)),
  text: (font: "Inter", size: 13pt),
  layouts: (
    content: layouts.content(),
    title: layouts.title(),
    section: layouts.section(),
  ),
  apply: apply,
)

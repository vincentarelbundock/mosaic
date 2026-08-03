// Passive Cream design definition; the Mosaic engine owns setup.
#import "layouts.typ" as layouts
#import "tokens.typ" as tokens

#let text-style(options) = (font: options.font, size: options.base-size)
#let apply(body, colors: (:), options: (:)) = {
  let base-size = options.base-size
  show heading.where(level: 1): set text(size: base-size * 1.9, weight: "bold")
  show heading.where(level: 2): set text(size: base-size * 1.25, weight: "bold")
  show heading: set block(below: 0.5em)
  show label("mosaic-cell-title"): set align(left + horizon)
  show label("mosaic-cell-title"): it => block(
    width: 100%, height: 100%, fill: colors.surface,
    text(fill: colors.text, it),
  )
  show label("mosaic-cell-section"): set align(left + horizon)
  show label("mosaic-cell-section"): set text(size: base-size, weight: "regular")
  show label("mosaic-cell-section"): it => block(width: 100%)[
    #it
    #v(0.5em)
    #line(length: 30%, stroke: 1pt + colors.line)
  ]
  body
}
#let definition = (
  name: "Cream",
  colors: tokens.colors,
  defaults: (spacing: (inset: 42pt)),
  options: (font: "Inter", base-size: 18pt),
  text: text-style,
  layouts: (
    content: layouts.content(),
    title: layouts.title(),
    section: layouts.section(),
  ),
  apply: apply,
)

// Passive Minimalist design definition; the Mosaic engine owns setup.
#import "layouts.typ" as layouts
#import "tokens.typ" as tokens

#let text-style(options) = (font: options.font, size: options.base-size)
#let apply(body, colors: (:), options: (:)) = {
  let base-size = options.base-size
  show heading.where(level: 1): set text(size: base-size * 2.2, weight: "bold")
  show heading.where(level: 2): set text(size: base-size * 1.79, weight: "bold")
  show heading: set block(below: 0.6em)
  show label("mosaic-cell-title"): set align(left + horizon)
  show label("mosaic-cell-section"): set text(size: base-size, weight: "regular")
  body
}
#let definition = (
  name: "Minimalist",
  colors: tokens.colors,
  defaults: (spacing: (inset: 45pt)),
  options: (font: "Source Serif 4", base-size: 14pt),
  text: text-style,
  layouts: (
    content: layouts.content(),
    title: layouts.title(),
    section: layouts.section(),
  ),
  apply: apply,
)

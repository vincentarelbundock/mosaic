// Passive Metropolis design definition; the Mosaic engine owns setup.
#import "../../component-api.typ" as components
#import "layouts.typ" as layouts
#import "tokens.typ" as tokens

#let text-style(options) = (font: options.font, size: options.base-size)
#let apply(body, colors: (:), options: (:)) = {
  let base-size = options.base-size
  show raw: set text(font: options.font-mono)
  show raw.where(block: false): set text(size: 1.125em)
  show raw.where(block: true): set text(size: 0.65em)
  show heading.where(depth: 2): set text(size: 0.75em, weight: "regular")
  show label("mosaic-cell-header"): it => block(
    width: 100%, fill: colors.text,
    text(fill: colors.canvas, weight: "medium", it),
  )
  show label("mosaic-cell-body"): set align(horizon)
  show label("mosaic-cell-title"): set text(fill: colors.text)
  show label("mosaic-cell-section"): set align(left + horizon)
  show label("mosaic-cell-section"): set text(size: base-size, weight: "regular")
  show label("mosaic-cell-section"): it => block(width: 100%)[
    #it
    #v(0.4em)
    #components.progress(
      variant: "line", count: "sections", width: 100%, thickness: 3.01pt,
      track: colors.line, color: colors.accent,
    )
  ]
  body
}
#let definition = (
  name: "Metropolis",
  colors: tokens.colors,
  defaults: (paper: "16-9"),
  options: (font: "Fira Sans", font-mono: "Fira Mono", base-size: 21.5pt),
  text: text-style,
  layouts: (
    content: layouts.content(),
    title: layouts.title(),
    section: layouts.section(),
  ),
  apply: apply,
)

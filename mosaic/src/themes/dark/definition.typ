// Passive Dark design definition; the Mosaic engine owns setup.
#import "layouts.typ" as layouts
#import "tokens.typ" as tokens

#let code-theme = read("code.tmTheme", encoding: none)
#let text-style(options) = (font: options.font, size: options.base-size)
#let apply(body, colors: (:), options: (:)) = {
  set table(stroke: 0.8pt + colors.line)
  set raw(theme: code-theme)
  show link: set text(fill: colors.accent)
  show raw: set text(font: options.font-mono)
  show raw.where(block: false): set text(fill: colors.accent)
  show raw.where(block: true): set text(size: 0.68em)
  show raw.where(block: true): it => block(
    width: 100%, fill: colors.surface, stroke: 0.8pt + colors.line,
    radius: 7pt, inset: (x: 14pt, y: 11pt), it,
  )
  show heading: set text(weight: "semibold", fill: colors.text)
  show label("mosaic-cell-header"): it => block(width: 100%)[
    #text(fill: colors.text, weight: "semibold", it)
    #v(0.18em)
    #line(length: 100%, stroke: 0.8pt + colors.line)
  ]
  show label("mosaic-cell-footer"): set text(fill: colors.muted)
  show label("mosaic-cell-title"): set align(left + horizon)
  show label("mosaic-cell-title"): set text(fill: colors.text)
  show label("mosaic-cell-section"): set align(left + horizon)
  show label("mosaic-cell-section"): set text(fill: colors.text)
  show label("mosaic-cell-section"): it => block(
    width: 100%, inset: (left: 20pt),
    stroke: (left: 4pt + colors.accent), it,
  )
  body
}
#let definition = (
  name: "Dark",
  colors: tokens.colors,
  options: (
    font: ("Inter", "Source Sans 3", "Liberation Sans", "DejaVu Sans"),
    font-mono: "DejaVu Sans Mono",
    base-size: 28pt,
  ),
  text: text-style,
  layouts: (
    content: layouts.content(),
    title: layouts.title(),
    section: layouts.section(),
  ),
  apply: apply,
)

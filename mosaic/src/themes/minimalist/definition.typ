// Passive Minimalist design definition; the Mosaic engine owns setup.
//
// The engine emits no typography, so this states the complete look: base type,
// headings, captions, list rhythm, and the canonical <mosaic-cell-*>
// vocabulary, kept deliberately undecorated.
#import "../extension.typ": normalize-lists
#import "layouts.typ" as layouts
#import "tokens.typ" as tokens

#let apply(body, colors: (:), options: (:)) = {
  let base-size = options.base-size
  set text(
    font: options.font,
    size: base-size,
    fill: colors.text,
    fallback: true,
  )
  show: normalize-lists
  set list(spacing: 0.9em)
  set enum(spacing: 0.9em)
  set terms(spacing: 0.9em)
  show heading.where(level: 1): set text(size: base-size * 2.2, weight: "bold")
  show heading.where(level: 2): set text(size: base-size * 1.79, weight: "bold")
  show heading: set block(below: 0.6em)
  show figure.caption: set text(size: 0.72em, fill: colors.muted)
  show label("mosaic-title-display"): set text(
    size: 2em, weight: "semibold", tracking: -0.015em,
  )
  show label("mosaic-cell-title"): set par(leading: 0.42em)
  show label("mosaic-cell-title"): set align(left + horizon)
  show label("mosaic-cell-section"): set align(center + horizon)
  show label("mosaic-cell-section"): set text(size: base-size, weight: "regular")
  show label("mosaic-cell-footer"): set text(size: 0.55em, fill: colors.muted)
  show label("mosaic-cell-authors"): set text(size: 0.8em, weight: "medium")
  show label("mosaic-cell-details"): set text(size: 0.55em, fill: colors.muted)
  body
}
#let definition = (
  name: "Minimalist",
  colors: tokens.colors,
  defaults: (spacing: (inset: 45pt)),
  options: (font: "Source Serif 4", base-size: 14pt),
  layouts: (
    content: layouts.content(),
    title: layouts.title(),
    section: layouts.section(),
  ),
  apply: apply,
)

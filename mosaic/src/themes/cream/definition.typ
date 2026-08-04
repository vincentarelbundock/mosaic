// Passive Cream design definition; the Mosaic engine owns setup.
//
// The engine emits no typography, so this states the complete look: base type,
// headings, captions, list rhythm, and the canonical <mosaic-cell-*>
// vocabulary, with Cream's surface-backed title and ruled section on top.
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
  show heading.where(level: 1): set text(size: base-size * 1.9, weight: "bold")
  show heading.where(level: 2): set text(size: base-size * 1.25, weight: "bold")
  show heading: set block(below: 0.5em)
  show figure.caption: set text(size: 0.72em, fill: colors.muted)
  show label("mosaic-title-display"): set text(
    size: 2em, weight: "semibold", tracking: -0.015em,
  )
  show label("mosaic-cell-title"): set par(leading: 0.42em)
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
  show label("mosaic-cell-footer"): set text(size: 0.55em, fill: colors.muted)
  show label("mosaic-cell-authors"): set text(size: 0.8em, weight: "medium")
  show label("mosaic-cell-details"): set text(size: 0.55em, fill: colors.muted)
  body
}
#let definition = (
  name: "Cream",
  colors: tokens.colors,
  defaults: (spacing: (inset: 42pt)),
  options: (font: "Inter", base-size: 18pt),
  layouts: (
    content: layouts.content(),
    title: layouts.title(),
    section: layouts.section(),
  ),
  apply: apply,
)

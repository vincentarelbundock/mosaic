// Passive Greyscale definition vendored with this deck.
//
// Mosaic's engine emits no typography, so this states the whole look,
// including the canonical <mosaic-cell-*> vocabulary.
#import "@local/mosaic:0.0.1": theme
#import "theme-layouts.typ" as layouts
#import "theme-tokens.typ" as tokens

#let apply(body, colors: (:), options: (:)) = {
  set text(font: "Inter", size: 13pt, fill: colors.text)
  show: theme.normalize-lists
  show heading.where(depth: 1): set text(size: 2em, weight: "bold")
  show heading.where(depth: 2): set text(size: 1.4em, weight: "bold")
  show heading: set block(below: 0.75em)
  show figure.caption: set text(size: 0.72em, fill: colors.muted)
  show label("mosaic-cell-header"): it => block(width: 100%)[
    #it
    #line(length: 100%, stroke: 0.6pt + colors.line)
  ]
  show label("mosaic-cell-title"): set text(
    size: 2em, weight: "semibold", tracking: -0.015em,
  )
  show label("mosaic-cell-title"): set par(leading: 0.42em)
  show label("mosaic-cell-title"): set align(left + horizon)
  show label("mosaic-cell-title"): it => block(
    width: 100%, height: 100%, fill: colors.text,
    text(fill: colors.canvas, it),
  )
  show label("mosaic-cell-section"): set align(left + horizon)
  show label("mosaic-cell-section"): set text(size: 2em, weight: "semibold")
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
  show label("mosaic-cell-footer"): set text(size: 0.55em, fill: colors.muted)
  show label("mosaic-cell-authors"): set text(size: 0.8em, weight: "medium")
  show label("mosaic-cell-details"): set text(size: 0.55em, fill: colors.muted)
  body
}
#let definition = (
  name: "Greyscale",
  colors: tokens.colors,
  defaults: (spacing: (inset: 40pt)),
  layouts: (
    content: layouts.content(),
    title: layouts.title(),
    section: layouts.section(),
  ),
  apply: apply,
)

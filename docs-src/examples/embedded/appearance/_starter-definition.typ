// Passive starter definition: design values and native rules only.
//
// Mosaic's engine states only the base typography: the font and base size
// from `defaults` below and the text color from the palette. A theme states
// the rest of its look here, including the canonical <mosaic-cell-*>
// vocabulary the layouts compose against.
#import "_starter-layouts.typ" as layouts

#let _navy = rgb("#1f2a44")
#let _gold = rgb("#d9a441")

#let apply(body, colors: (:), options: (:)) = {
  show list.where(tight: true): it => list(tight: false, ..it.children)
  show enum.where(tight: true): it => enum(tight: false, ..it.children)
  // Multiples of the base size rather than em, so a heading keeps its size
  // under `set heading(offset: ..)`.
  show heading.where(depth: 1): set text(
    size: options.base-size * 2.8, weight: "semibold",
  )
  show heading.where(depth: 2): set text(
    size: options.base-size * 1.7, weight: "semibold",
  )
  show heading: set block(below: 0.75em)
  show figure.caption: set text(size: 0.72em, fill: colors.muted)
  show label("mosaic-title-display"): set text(
    size: 2em, weight: "semibold", tracking: -0.015em,
  )
  show label("mosaic-cell-title"): set par(leading: 0.42em)
  show label("mosaic-cell-section"): set align(center + horizon)
  show label("mosaic-cell-section"): set text(size: 2em, weight: "semibold")
  show label("mosaic-cell-section"): it => block(
    width: 100%, height: 100%, fill: colors.accent, it,
  )
  show label("mosaic-cell-footer"): set text(size: 0.55em, fill: colors.muted)
  show label("mosaic-cell-authors"): set text(size: 0.8em, weight: "medium")
  show label("mosaic-cell-details"): set text(size: 0.55em, fill: colors.muted)
  body
}
#let definition = (
  name: "Starter",
  colors: (
    canvas: rgb("#f4f1ea"),
    surface: white,
    text: _navy,
    muted: _navy.lighten(25%),
    line: _navy.lighten(55%),
    accent: _gold,
    warning: rgb("#E69F00"),
    error: rgb("#D55E00"),
  ),
  defaults: (font: "Inter", base-size: 20pt),
  layouts: (
    content: layouts.content(),
    title: layouts.title(),
    section: layouts.section(),
  ),
  apply: apply,
)

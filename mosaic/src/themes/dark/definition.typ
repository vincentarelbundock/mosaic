// Passive Dark design definition; the Mosaic engine owns setup.
//
// The engine emits no typography, so this states the complete look: base type,
// headings, captions, list rhythm, the canonical <mosaic-cell-*> vocabulary,
// and Dark's own code, table, and link treatments.
#import "layouts.typ" as layouts
#import "tokens.typ" as tokens

#let code-theme = read("code.tmTheme", encoding: none)
#let apply(body, colors: (:), options: (:)) = {
  set text(
    font: options.font,
    size: options.base-size,
    fill: colors.text,
    fallback: true,
  )
  show list.where(tight: true): it => list(tight: false, ..it.children)
  show enum.where(tight: true): it => enum(tight: false, ..it.children)
  set list(spacing: 0.9em)
  set enum(spacing: 0.9em)
  set terms(spacing: 0.9em)
  show heading.where(depth: 1): set text(size: 2em, weight: "semibold")
  show heading.where(depth: 2): set text(size: 1.4em, weight: "semibold")
  show heading: set text(weight: "semibold", fill: colors.text)
  show heading: set block(below: 0.75em)
  show figure.caption: set text(size: 0.72em, fill: colors.muted)
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
  show label("mosaic-cell-header"): it => block(width: 100%)[
    #text(fill: colors.text, weight: "semibold", it)
    #v(0.18em)
    #line(length: 100%, stroke: 0.8pt + colors.line)
  ]
  show label("mosaic-cell-title"): set text(fill: colors.text)
  show label("mosaic-title-display"): set text(
    size: 2em, weight: "semibold", tracking: -0.015em,
  )
  show label("mosaic-cell-title"): set par(leading: 0.42em)
  show label("mosaic-cell-title"): set align(left + horizon)
  show label("mosaic-cell-section"): set text(
    size: 2em, weight: "semibold", fill: colors.text,
  )
  show label("mosaic-cell-section"): set align(left + horizon)
  show label("mosaic-cell-section"): it => block(
    width: 100%, inset: (left: 20pt),
    stroke: (left: 4pt + colors.accent), it,
  )
  show label("mosaic-cell-footer"): set text(size: 0.55em, fill: colors.muted)
  show label("mosaic-cell-authors"): set text(size: 0.8em, weight: "medium")
  show label("mosaic-cell-details"): set text(size: 0.55em, fill: colors.muted)
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
  layouts: (
    content: layouts.content(variant: "header-body-footer"),
    title: layouts.title(),
    section: layouts.section(),
  ),
  apply: apply,
)

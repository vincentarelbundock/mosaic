// Passive Metropolis design definition; the Mosaic engine owns setup.
//
// The engine emits no typography, so this states the complete look: base type,
// headings, captions, list rhythm, and the canonical <mosaic-cell-*>
// vocabulary, plus Metropolis's inverted header bar and progress-ruled section.
#import "../../component/api.typ" as components
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
  show list.where(tight: true): it => list(tight: false, ..it.children)
  show enum.where(tight: true): it => enum(tight: false, ..it.children)
  set list(spacing: 0.9em)
  set enum(spacing: 0.9em)
  set terms(spacing: 0.9em)
  show heading.where(depth: 1): set text(size: 2em, weight: "semibold")
  show heading.where(depth: 2): set text(size: 0.75em, weight: "regular")
  show heading: set block(below: 0.75em)
  show figure.caption: set text(size: 0.72em, fill: colors.muted)
  show raw: set text(font: options.font-mono)
  show raw.where(block: false): set text(size: 1.125em)
  show raw.where(block: true): set text(size: 0.65em)
  show label("mosaic-cell-header"): it => block(
    width: 100%, fill: colors.text,
    text(fill: colors.canvas, weight: "medium", it),
  )
  show label("mosaic-cell-body"): set align(horizon)
  show label("mosaic-cell-title"): set text(fill: colors.text)
  show label("mosaic-title-display"): set text(
    size: 2em, weight: "semibold", tracking: -0.015em,
  )
  show label("mosaic-cell-title"): set par(leading: 0.42em)
  show label("mosaic-cell-section"): set align(left + horizon)
  show label("mosaic-cell-section"): set text(size: base-size, weight: "regular")
  show label("mosaic-cell-section"): it => block(width: 100%)[
    #it
    #v(0.4em)
    // The 3.01pt thickness is unexplained: it is visually indistinguishable
    // from 3pt and reads as a leftover from tuning rather than a workaround
    // for anything reproducible. Left as-is because changing it changes this
    // theme's rendered output, which is a design call rather than a cleanup.
    #components.progress(
      variant: "line", count: "sections", width: 100%, thickness: 3.01pt,
      fill: colors.line, accent: colors.accent,
    )
  ]
  show label("mosaic-cell-footer"): set text(size: 0.55em, fill: colors.muted)
  show label("mosaic-cell-authors"): set text(size: 0.8em, weight: "medium")
  show label("mosaic-cell-details"): set text(size: 0.55em, fill: colors.muted)
  body
}
#let definition = (
  name: "Metropolis",
  colors: tokens.colors,
  options: (font: "Fira Sans", font-mono: "Fira Mono", base-size: 21.5pt),
  layouts: (
    content: layouts.content(),
    title: layouts.title(),
    section: layouts.section(),
  ),
  apply: apply,
)

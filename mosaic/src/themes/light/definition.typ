// Canonical passive Light definition.
//
// Mosaic's engine emits no typography at all, so a theme states its complete
// look here: base type, headings, captions, list rhythm, and the canonical
// <mosaic-cell-*> vocabulary that the layouts compose against. Light is the
// plainest complete statement of that set, which makes it the file to copy
// when starting a theme from scratch.
#import "../../color-defaults.typ": default-colors

#let apply(body, colors: (:), options: (:)) = {
  set text(
    font: options.font,
    size: options.base-size,
    fill: colors.text,
    fallback: true,
  )
  show heading.where(depth: 1): set text(size: 2em, weight: "semibold")
  show heading.where(depth: 2): set text(size: 1.4em, weight: "semibold")
  show heading: set block(below: 0.75em)
  show figure.caption: set text(size: 0.72em, fill: colors.muted)
  set list(spacing: 0.8em)
  set enum(spacing: 0.8em)
  set terms(spacing: 0.8em)
  show label("mosaic-cell-title"): set text(
    size: 2em, weight: "semibold", tracking: -0.015em,
  )
  show label("mosaic-cell-title"): set par(leading: 0.42em)
  show label("mosaic-cell-section"): set align(center + horizon)
  show label("mosaic-cell-section"): set text(size: 2em, weight: "semibold")
  show label("mosaic-cell-footer"): set text(size: 0.55em, fill: colors.muted)
  show label("mosaic-cell-authors"): set text(size: 0.8em, weight: "medium")
  show label("mosaic-cell-details"): set text(size: 0.55em, fill: colors.muted)
  body
}

#let definition = (
  name: "Light",
  colors: default-colors,
  options: (
    font: (
      "Inter",
      "Source Sans 3",
      "Liberation Sans",
      "DejaVu Sans",
      "Libertinus Serif",
    ),
    base-size: 28pt,
  ),
  apply: apply,
)

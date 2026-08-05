// Everything main.typ imports: the shared Mosaic API, a deck-local Mosaic
// theme, and the two slide shapes Calmly has that Mosaic has no layout for.
//
// The theme re-creates the look of the Calmly theme for
// Touying (https://github.com/YHan228/calmly-touying, MIT): a full-bleed blue
// header bar, a progress line and slide counter along the bottom edge, quiet
// grey body text, and olive bullets.
//
// This is a design, not a transcription. It states the palette and the few
// structural gestures that make Calmly recognizable, and leaves everything
// else to Mosaic's defaults.
#import "@local/mosaic:0.0.1" as mosaic
#import mosaic: slide, note, fit, surface, grids, layouts, steps, components

// Calmly's "tomorrow" palette, light variant. Six names are the deck's own
// chrome and two are the status colors components paint with.
#let colors = (
  canvas: rgb("#ffffff"),
  surface: rgb("#efefef"),
  text: rgb("#1d1f21"),
  muted: rgb("#8e908c"),
  line: rgb("#e0e0e0"),
  accent: rgb("#4271ae"),
  warning: rgb("#eab700"),
  error: rgb("#c82829"),
)

// Calmly's secondary accent, which is not one of Mosaic's semantic names: it
// marks bullets, opens the progress gradient, and tints the example callout.
#let olive = rgb("#718c00")

// The short rule under a section title, sweeping from one accent to the other.
#let accent-rule = box(
  width: 4em,
  height: 0.1em,
  radius: 0.05em,
  fill: gradient.linear(olive, colors.accent),
)

// The bottom edge chrome. It is the real `footer` cell rather than a
// foreground plane, so the layouts that carry no footer (title, section, and
// the focus and standout slides below) drop it without being told.
#let footer-chrome = grid(
  columns: (1fr, auto),
  column-gutter: 1.2em,
  align: horizon,
  mosaic.components.progress(
    variant: "line",
    count: "slides",
    width: 100%,
    thickness: 2pt,
    accent: colors.accent,
    fill: colors.line,
  ),
  mosaic.components.progress(variant: "1/1", accent: colors.muted),
)

// Calmly's section divider: the title over the short accent rule. The rule is
// a real grid row rather than content appended by a show rule, because the
// section cell fits its own content and anything appended would land outside
// the fitted region.
#let section-layout = mosaic.grids.rows(
  mosaic.grids.track(1fr, mosaic.grids.cell("section-space-above", content: [])),
  mosaic.grids.track(auto, "section"),
  mosaic.grids.track(auto, mosaic.grids.cell(
    "section-rule",
    content: align(center, accent-rule),
  )),
  mosaic.grids.track(1fr, mosaic.grids.cell("section-space-below", content: [])),
)

#let apply(body, colors: (:), options: (:)) = {
  // Body copy sits one step lighter than the ink, so headings and bold runs
  // carry the emphasis without a second color.
  set text(
    font: options.font,
    size: options.base-size,
    fill: colors.text.lighten(20%),
    fallback: true,
  )
  set list(marker: text(fill: olive)[•])
  set enum(numbering: n => text(fill: colors.accent, weight: "medium")[#n.])
  set table(stroke: 0.6pt + colors.line)
  show link: set text(fill: colors.accent)
  show figure.caption: set text(size: 0.72em, fill: colors.muted, style: "italic")

  // Stated absolutely: the level-1 heading scale and the section cell's scale
  // are both em multipliers, so an em size here would compound and a
  // `= Heading` section would outgrow an explicit section slide.
  let section-size = options.base-size * 1.75
  show heading: set text(fill: colors.text, weight: "semibold")
  show heading.where(depth: 1): set text(size: section-size)
  show heading.where(depth: 2): set text(size: 1.45em)

  show raw: set text(font: options.font-mono)
  show raw.where(block: true): set text(size: 0.7em)
  show raw.where(block: true): block.with(
    width: 100%,
    fill: colors.surface,
    stroke: 0.5pt + colors.line,
    radius: 8pt,
    inset: 0.9em,
  )

  // The signature header: a full-bleed bar in the accent color with the slide
  // title knocked out of it. The cell inset lives inside the label, so this
  // wrapper paints edge to edge and the heading keeps its padding. The heading
  // rule above sets its own fill, and a `set` rule beats the surrounding text
  // fill, so the bar restates the knockout color for headings too.
  show label("mosaic-cell-header"): it => block(
    width: 100%,
    fill: colors.accent,
    {
      show heading: set text(fill: colors.canvas)
      text(fill: colors.canvas, it)
    },
  )

  show label("mosaic-title-display"): set text(size: 1.85em, weight: "semibold")
  show label("mosaic-cell-title"): set text(fill: colors.text)
  show label("mosaic-cell-footer"): set text(size: 0.6em, fill: colors.muted)
  show label("mosaic-cell-section"): set align(center)
  show label("mosaic-cell-section"): set text(size: section-size, weight: "semibold", fill: colors.text)

  body
}

#let definition = (
  name: "Calmly",
  colors: colors,
  defaults: (
    cells: (footer: footer-chrome),
    // The deck gap is the title stack's vertical rhythm: the `ruled` variant
    // states its gaps as multiples of it, and Calmly's title page is airy.
    spacing: (gap: 1.6em),
  ),
  options: (
    font: ("Source Sans 3", "Inter", "Liberation Sans", "DejaVu Sans"),
    font-mono: ("JetBrains Mono", "DejaVu Sans Mono"),
    base-size: 20pt,
  ),
  layouts: (
    content: mosaic.layouts.content(variant: "header-body-footer"),
    // Calmly rules its title page with a neutral hairline rather than the
    // accent, which the `accent:` field states without a new variant.
    title: mosaic.layouts.title(variant: "ruled", accent: rgb("#c8c8c8")),
    section: section-layout,
  ),
  apply: apply,
)

#let setup = mosaic.themes.setup(definition)

// Calmly's focus slide: the accent gradient edge to edge, one line of display
// type knocked out of it. An ordinary body-only slide with a painted
// background plane.
#let focus-slide(body) = {
  show label("mosaic-cell-body"): set align(center + horizon)
  show label("mosaic-cell-body"): set text(fill: white, size: 2.2em, weight: "medium")
  slide(
    layout: layouts.content(variant: "body"),
    background: rect(
      width: 100%,
      height: 100%,
      fill: gradient.linear(angle: 135deg, olive, colors.accent, colors.accent.darken(25%)),
    ),
  )[#body]
}

// Calmly's standout slide: the same shape at maximum contrast. `invert: true`
// swaps canvas and text for one slide, and the body states the accent tint
// Calmly puts on the type.
#let standout-slide(body) = {
  show label("mosaic-cell-body"): set align(center + horizon)
  show label("mosaic-cell-body"): set text(fill: rgb("#81a2be"), size: 2.2em, weight: "semibold")
  slide(layout: layouts.content(variant: "body"), invert: true)[#body]
}

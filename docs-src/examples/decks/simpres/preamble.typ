// Everything main.typ imports: the shared Mosaic API, CeTZ for the one drawn
// figure, and a deck-local Mosaic theme.
//
// The theme re-creates the look of the Simpres theme for
// Touying (https://github.com/thy0s/touying-simpres, MIT): a navy header band
// carrying the section name over the slide title, a ruled title page, a
// section divider over a progress bar, and a navy focus slide.
//
// This is a design, not a transcription. It states the palette and the few
// structural gestures that make Simpres recognizable, and leaves everything
// else to Mosaic's defaults.
#import "@preview/mosaic:0.0.1" as mosaic
#import mosaic: slide, note, fit, surface, grids, layouts, steps, components
#import "@preview/cetz:0.5.2"

// Simpres names four colors. Mosaic's palette has eight, so the remaining
// four are picked to sit with the navy rather than borrowed from Simpres.
#let colors = (
  canvas: rgb("#ffffff"),
  surface: rgb("#cce5ff"),
  text: rgb("#000000"),
  muted: rgb("#4d4d4d"),
  line: rgb("#99c2e6"),
  accent: rgb("#003366"),
  warning: rgb("#b45309"),
  error: rgb("#b00020"),
)

// The bottom edge: whatever the deck declared as its date on the left, the
// slide counter on the right. It is the real `footer` cell rather than a
// foreground plane, so the title, section, and focus slides drop it without
// being told.
#let footer-chrome = grid(
  columns: (1fr, auto),
  column-gutter: 1em,
  context {
    let date = mosaic.info().date
    if date != none { date }
  },
  mosaic.components.progress(variant: "1/1", accent: colors.text),
)

#let apply(body, colors: (:), options: (:)) = {
  set text(
    font: options.font,
    size: options.base-size,
    fill: colors.text,
    fallback: true,
  )
  set table(stroke: 0.8pt + colors.line)
  show link: set text(fill: colors.accent)
  show figure.caption: set text(size: 0.5em)
  show raw: set text(font: options.font-mono)
  show raw.where(block: true): set text(size: 0.5em)

  show heading: set text(weight: "bold")
  show heading.where(depth: 1): set text(size: 1.8em, fill: colors.accent)
  show heading.where(depth: 2): set text(size: 1.26em)

  // Simpres puts the current section name above the slide title, in the same
  // band and at the band's small size. The kicker is prepended here, inside
  // the heading, so it lands within the header cell's own padding.
  show heading.where(depth: 2): it => {
    context {
      let sections = query(heading.where(level: 1).before(here()))
      if sections.len() > 0 {
        block(below: 0.3em, text(size: 0.55em, weight: "regular", sections.last().body))
      }
    }
    it.body
  }

  // The signature band: full-bleed navy with the title knocked out of it. The
  // cell inset lives inside the label, so this wrapper paints edge to edge and
  // the heading keeps its padding. The heading rule above sets its own fill,
  // and a `set` rule beats the surrounding text fill, so the band restates the
  // knockout color for headings too.
  show label("mosaic-cell-header"): it => block(
    width: 100%,
    fill: colors.accent,
    {
      show heading: set text(fill: colors.canvas)
      text(fill: colors.canvas, it)
    },
  )

  show label("mosaic-title-display"): set text(size: 1.5em, weight: "bold", fill: colors.accent)
  show label("mosaic-cell-details"): set text(fill: colors.text)
  show label("mosaic-cell-footer"): set text(size: 0.7em)
  show label("mosaic-cell-section"): set align(left + bottom)
  show label("mosaic-cell-section"): set text(size: 1.8em, weight: "bold", fill: colors.accent)

  body
}

#let definition = (
  name: "Simpres",
  colors: colors,
  defaults: (cells: (footer: footer-chrome)),
  options: (
    font: ("Source Sans 3", "Liberation Sans", "DejaVu Sans"),
    font-mono: ("Source Code Pro", "DejaVu Sans Mono"),
    base-size: 22pt,
  ),
  layouts: (
    content: mosaic.layouts.content(variant: "header-body-footer"),
    // Simpres rules its title page with a heavy bar in the primary color,
    // which is what the `ruled` variant draws once it takes the accent.
    title: mosaic.layouts.title(variant: "ruled"),
    // Simpres rules its section divider with a filling progress bar. The stock
    // `baseline` variant is the near neighbor: the same flush-left title over
    // a full-width rule, with the section number on the same baseline. Close
    // enough that a bespoke grid is not worth owning.
    section: mosaic.layouts.section(variant: "baseline"),
  ),
  apply: apply,
)

#let setup = mosaic.themes.setup(definition)

// Preamble for the Metropolis-style technical deck: imports, palette, slide
// constructors, theme, and inline helpers. main.typ imports this with `*` and
// applies the theme via `#show: deck-theme`.
//   - mosaic   : slide layout, grids, incremental reveals (`m.reduce`, `m.on`)
//   - fletcher : node/edge diagrams (the state machine)
//   - cetz     : general vector drawing (the Bloch sphere)
//   - calepin  : executes embedded R chunks at compile time and caches results
#import "@local/mosaic:0.0.1" as m
#import "@preview/fletcher:0.5.8" as fletcher
#import "@preview/cetz:0.5.2"
#import "/.calepin/calepin.typ" as calepin

// ── Palette ──────────────────────────────────────────────────────────────
// Metropolis's signature ink/orange scheme, plus a few accent colors used to
// tint individual terms in the Bellman equation.
#let ink = rgb("#23373b")
#let orange = rgb("#f28e2b")
#let paper = rgb("#fafafa")
#let soft = rgb("#dddddd")
#let blue = rgb("#2563eb")
#let green = rgb("#15803d")
#let red = rgb("#c2410c")
#let sans = "Fira Sans"
#let mono = "Fira Mono"

// ═══════════════════════════════════════════════════════════════════════════
//  Slide constructors
//
//  `slide` is the ordinary content slide. It is registered as `auto-slide` in
//  the theme below, so plain `== Title` markup renders through it — no explicit
//  `#slide(...)` call needed. `slide` must be defined before the theme wrapper
//  because `m.setup` captures it. `slide-title` and `slide-section` are ordinary
//  helpers called explicitly from the content.
// ═══════════════════════════════════════════════════════════════════════════

// Bottom-right slide-number / progress dot, shown on ordinary frames and
// suppressed (number: false) on the reference and backup slides.
#let footer(number: true) = [
  #if number {
    place(bottom + right, dx: -0.9em, dy: -0.7em)[
      #text(size: 0.48em)[
        #m.components.progress(variant: "1", color: rgb("#667477"))
      ]
    ]
  }
]

// Shared "header-body" layout for ordinary content slides: an inverted
// (dark) title bar above a left-aligned, vertically centered body.
#let slide-grid = m.templates.default(
  variant: "header-body",
  // Invert the header (dark bar, light text); the medium weight is the only
  // typographic tweak — size and color come from the theme. Insets are left at
  // Mosaic's standard spacing.inset.
  inverted: ("header",),
  text: (header: (weight: "medium")),
  align: (body: left + horizon),
)

// A standard content slide: `slide(title, body)`. The two content blocks map
// to the header and body cells of `slide-grid`. The body is left-aligned by
// default; use `#set align(center)` in the body when a slide needs its content
// centered (e.g. a single diagram).
#let slide(title, body, number: true) = m.slide(
  grid: slide-grid,
  foreground: footer(number: number),
)[#title][#body]

// ── Theme ────────────────────────────────────────────────────────────────
// Applied in main.typ via `#show: deck-theme`. Show/set rules cannot cross an
// `#import`, so the palette registration and document-wide typography live in
// this wrapper rather than at the top level of the preamble. `setup` wires the
// colors into every built-in cell (title, section, questions, ...).
#let deck-theme(body) = {
  show: m.setup.with(
    paper: "16-9",
    colors: (
      canvas: paper,
      surface: paper,
      accent: orange,
      text: ink,
      inverse-text: paper,
      muted: rgb("#657377"),
      line: soft,
    ),
    // Route every `== Title` heading through the `slide` helper above, so
    // ordinary content is written as headings yet keeps the inverted header bar
    // and footer dot. Mosaic's standard inset (1.25em) is left in place.
    auto-slide: slide,
  )
  // The base font size is the single pt anchor; every other size below is
  // expressed as a multiple of it (em) so the deck scales as a unit.
  // `m.setup` already derives the default fill from the palette. Leaving the
  // fill unset here lets inverted cells replace it with `inverse-text`.
  set text(font: sans, size: 21.5pt)
  // Inline code should track the surrounding text size; only code blocks
  // drop to a compact size. Em factors here compound with Typst's built-in
  // 0.8em raw styling: inline 1.125 × 0.8 = 0.9 × surrounding, blocks
  // 0.65 × 0.8 = 0.52 × body. A single `show raw` size rule would also
  // compound inside already-small text and render inline code tiny.
  show raw: set text(font: mono)
  show raw.where(block: false): set text(size: 1.125em)
  show raw.where(block: true): set text(size: 0.65em)
  // Slide titles (`== ...`, routed through the header) default to Mosaic's
  // semibold 1.4em heading role. Metropolis wants a lighter, slightly smaller
  // title. This em compounds with the 1.4em role (0.75 × 1.4 ≈ 1.05 × body),
  // so the header lands just above body size.
  show heading.where(depth: 2): set text(size: 0.75em, weight: "regular")
  body
}

// ═══════════════════════════════════════════════════════════════════════════
//  Explicit slide constructors (title and section dividers)
// ═══════════════════════════════════════════════════════════════════════════

// Section-divider slide: large centered title over a progress bar that fills
// as we advance through the deck's sections.
#let slide-section(title) = {
  m.slide(
    grid: m.grid.cell("section"),
    section: true,
    cell-styles: (section: (fill: paper, align: left + horizon)),
  )[
    #text(size: 1.6em, weight: "medium")[#title]
    #v(0.4em)
    #m.components.progress(
      variant: "line",
      count: "sections",
      width: 100%,
      thickness: 3.01pt,
      track: rgb("#b8b1a8"),
      color: orange,
    )
  ]
}

// Opening slide built on Mosaic's `title` template ("academic" variant):
// a bottom-anchored title mass, the subtitle, an accent rule, then an inline
// author byline with affiliation superscripts and one fine-print legend line.
// The deck scheme (paper canvas, ink text, orange accent) styles it, so the
// cover stays visually consistent with the rest of the deck.
// `calepin.setup` runs once inside the title content to enable the R chunks
// used later in the deck.
#let slide-title(title, subtitle, authors, date) = m.slide(
  grid: m.templates.title(
    [
      #calepin.setup(echo: true, eval: true, results: "render")
      #title
    ],
    variant: "academic",
    subtitle: subtitle,
    authors: authors,
    date: date,
  ),
)

// ── Inline content helpers ─────────────────────────────────────────────────
// Small building blocks used *inside* a slide body rather than whole slides.
#let code(body) = text(font: mono, size: 0.65em, body)
#let alert(body) = text(fill: orange, body)
#let finding(title, body) = block(
  width: 100%,
  fill: soft.lighten(55%),
  inset: 0.5em,
)[
  #text(size: 0.74em, weight: "medium", fill: orange)[#title]
  #linebreak()
  #body
]

// Fixed-footprint annotations prevent incremental underbraces from moving
// neighboring terms or changing the equation's baseline.
#let dstrut = context { hide($j$) + h(-measure($j$).width) }
#let explained(color, term, label) = context {
  let braced = text(fill: color, $underbrace(#term #dstrut, #label)$)
  box(height: measure(text(fill: color, $#term$)).height, braced)
}

// `m.reduce` wraps a drawing package so that elements guarded by `m.on("2-",
// ...)` appear across successive reveals. `hide` keeps hidden elements in the
// layout (reserving their space) so nothing shifts as the diagram is built up.
#let state-diagram = m.reduce.with(
  render: fletcher.diagram,
  hide: fletcher.hide,
)

#let canvas = m.reduce.with(
  render: cetz.canvas,
  hide: cetz.draw.hide.with(bounds: true),
)

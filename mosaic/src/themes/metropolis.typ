// Metropolis: ink and orange, Fira Sans. A bundled Mosaic theme.
//
// Use it from the package namespace:
//   #import "@local/mosaic:0.0.1" as m
//   #show: m.themes.metropolis.apply
//   #m.themes.metropolis.title([My talk], subtitle: [A subtitle])
//
// `apply` exposes `font`, `font-mono`, and `base-size` knobs via
// `apply.with(...)`. For deeper customization, copy this file into your
// project, import it as a module, and edit it freely.
//
// Every bundled theme exports the same surface: `apply` (the document
// wrapper), `default`, `title`, and `section` (semantic layout factories),
// `colors` (the semantic Mosaic color roles), and `palette` (raw tokens).
#import "../setup.typ": setup
#import "../deck-commands.typ": slide
#import "../grid-api.typ" as grid
#import "../layout-api.typ" as semantic
#import "../component-api.typ" as components

// ── Palette ──────────────────────────────────────────────────────────────
// Metropolis's signature ink/orange scheme.
#let palette = (
  ink: rgb("#23373b"),
  orange: rgb("#f28e2b"),
  paper: rgb("#fafafa"),
  soft: rgb("#dddddd"),
  muted: rgb("#657377"),
  dot: rgb("#667477"),
  track: rgb("#b8b1a8"),
)

#let colors = (
  canvas: palette.paper,
  surface: palette.paper,
  accent: palette.orange,
  text: palette.ink,
  inverse-text: palette.paper,
  muted: palette.muted,
  line: palette.soft,
)

// ── Layouts ──────────────────────────────────────────────────────────────
// Bottom-right slide-number / progress dot, shown on ordinary frames and
// suppressed (number: false) on reference and backup slides.
#let footer(number: true) = [
  #if number {
    place(bottom + right, dx: -0.9em, dy: -0.7em)[
      #text(size: 0.48em)[
        #components.progress(variant: "1", color: palette.dot)
      ]
    ]
  }
]

// Shared "header-body" layout for ordinary content slides: an inverted
// (dark) title bar above a left-aligned, vertically centered body.
#let slide-grid = semantic.default(
  variant: "header-body",
  inverted: ("header",),
  text: (header: (weight: "medium")),
  align: (body: left + horizon),
)

// The ordinary content slide. Registered as `auto-slide` in `apply`, so
// plain `== Title` markup renders through it. `cell-styles` is forwarded to
// `slide` so decks can override the theme's defaults per slide.
#let default-layout(title, body, number: true, cell-styles: (:)) = slide(
  grid: slide-grid,
  cell-styles: cell-styles,
  foreground: footer(number: number),
)[#title][#body]

// Opening slide built on Mosaic's `title` layout ("academic" variant). The
// deck scheme (paper canvas, ink text, orange accent) styles it, so the
// cover stays visually consistent with the rest of the deck. `authors`
// takes an array of `mosaic.author(...)` records.
#let title-layout(
  title,
  subtitle: none,
  authors: (),
  date: none,
) = slide(
  grid: semantic.title(
    title,
    variant: "academic",
    subtitle: subtitle,
    authors: authors,
    date: date,
  ),
)

// Section-divider slide: large left-aligned title over a progress bar that
// fills as we advance through the deck's sections.
#let section-layout(title, subtitle: none, cell-styles: (:)) = slide(
  grid: grid.cell("section"),
  section: true,
  cell-styles: (
    section: (fill: palette.paper, align: left + horizon),
  ) + cell-styles,
)[
  #text(size: 1.6em, weight: "medium")[#title]
  #if subtitle != none [
    #v(0.2em)
    #text(size: 0.9em, fill: palette.muted)[#subtitle]
  ]
  #v(0.4em)
  #components.progress(
    variant: "line",
    count: "sections",
    width: 100%,
    thickness: 3.01pt,
    track: palette.track,
    color: palette.orange,
  )
]

// Semantic layout factories, exported at the module top level so decks can
// call them directly (Typst cannot call dictionary entries as functions).
// The `layouts` dictionary groups the same factories for programmatic use.
#let default = default-layout
#let title = title-layout
#let section = section-layout
#let layouts = (
  default: default-layout,
  title: title-layout,
  section: section-layout,
)

// ── Apply ────────────────────────────────────────────────────────────────
// Applied in the deck via `#show: theme.apply`. `setup` wires the colors
// into every built-in cell (title, section, questions, ...); everything
// else is a native `set` or `show` rule.
#let apply(
  body,
  font: "Fira Sans",
  font-mono: "Fira Mono",
  base-size: 21.5pt,
) = {
  show: setup.with(
    paper: "16-9",
    colors: colors,
    // Route every `== Title` heading through the default layout above, so
    // ordinary content is written as headings yet keeps the inverted header
    // bar and footer dot.
    auto-slide: default-layout,
  )
  // The base size is the single pt anchor; every other size is expressed as
  // a multiple of it (em) so the deck scales as a unit.
  set text(font: font, size: base-size)
  // Inline code should track the surrounding text size; only code blocks
  // drop to a compact size. Em factors here compound with Typst's built-in
  // 0.8em raw styling: inline 1.125 × 0.8 = 0.9 × surrounding, blocks
  // 0.65 × 0.8 = 0.52 × body.
  show raw: set text(font: font-mono)
  show raw.where(block: false): set text(size: 1.125em)
  show raw.where(block: true): set text(size: 0.65em)
  // Markup lists are "tight" by default, which packs bullets at line
  // leading. Rebuild them loose so items breathe without per-slide tuning.
  show list.where(tight: true): it => list(tight: false, ..it.children)
  show enum.where(tight: true): it => enum(tight: false, ..it.children)
  set list(spacing: 0.9em)
  set enum(spacing: 0.9em)
  // Slide titles (`== ...`, routed through the header) default to Mosaic's
  // semibold 1.4em heading role. Metropolis wants a lighter, slightly
  // smaller title (0.75 × 1.4 ≈ 1.05 × body).
  show heading.where(depth: 2): set text(size: 0.75em, weight: "regular")
  body
}

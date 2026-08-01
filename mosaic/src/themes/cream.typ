// Cream, Green, and Black: sage and cream, Inter. A bundled Mosaic theme.
//
// Use it from the package namespace:
//   #import "@local/mosaic:0.0.1" as m
//   #show: m.themes.cream.apply
//   #m.themes.cream.title([My talk], subtitle: [A subtitle])
//
// `apply` exposes `font` and `base-size` knobs via `apply.with(...)`. For
// deeper customization, copy this file into your project, import it as a
// module, and edit it freely.
//
// Every bundled theme exports the same surface: `apply` (the document
// wrapper), `default`, `title`, and `section` (semantic layout factories),
// `colors` (the semantic Mosaic color roles), and `palette` (raw tokens).
#import "../setup.typ": setup
#import "../deck-commands.typ": slide
#import "../grid-api.typ" as grid

// ── Palette ────────────────────────────────────────────────────────────────
#let palette = (
  sage: rgb("#aebdb3"),
  sage-dark: rgb("#93a69b"),
  cream: rgb("#f2eee5"),
  ink: rgb("#111111"),
  white: rgb("#f9f8f3"),
)

#let colors = (
  canvas: palette.sage,
  surface: palette.sage,
  accent: palette.cream,
  text: palette.white,
  inverse-text: palette.ink,
  muted: palette.cream,
  line: palette.white,
)

// ── Layouts ────────────────────────────────────────────────────────────────
// The ordinary content slide: a full-bleed sage surface with the heading and
// body stacked top-left. Registered as `auto-slide` in `apply`, so plain
// `== Title` markup renders through it. `cell-styles` is forwarded so decks
// can override the theme's defaults per slide.
#let default-layout(title, body, cell-styles: (:)) = slide(
  grid: grid.cell("content"),
  cell-styles: (
    content: (fill: palette.sage, inset: 42pt, align: top + left),
  ) + cell-styles,
)[
  #title
  #body
]

// Opening slide in the style of the deck's cover: a cream field, a large ink
// title over a thin rule, and a small byline. `authors` takes an array of
// `mosaic.author(...)` records; only the names are shown.
#let title-layout(
  title,
  subtitle: none,
  authors: (),
  date: none,
  cell-styles: (:),
) = slide(
  grid: grid.cell("cover"),
  cell-styles: (
    cover: (fill: palette.cream, inset: 42pt, align: left + horizon),
  ) + cell-styles,
  foreground: place(bottom + left, dx: 42pt, dy: -56pt)[
    #line(length: 55%, stroke: 1pt + palette.ink)
  ],
)[
  #set text(fill: palette.ink)
  #text(size: 2.6em, weight: "bold")[#title]
  #if subtitle != none [
    #v(0.2em)
    #text(size: 1.1em)[#subtitle]
  ]
  #if authors.len() > 0 or date != none [
    #v(1.4em)
    #text(size: 0.8em)[
      #authors.map(author => author.name).join(", ")
      #if authors.len() > 0 and date != none [ · ]
      #date
    ]
  ]
]

// Section-divider slide: a sage field with a bold white title over a short
// white rule.
#let section-layout(title, subtitle: none, cell-styles: (:)) = slide(
  grid: grid.cell("section"),
  section: true,
  cell-styles: (
    section: (fill: palette.sage, inset: 42pt, align: left + horizon),
  ) + cell-styles,
)[
  #text(size: 1.9em, weight: "bold", fill: palette.white)[#title]
  #if subtitle != none [
    #v(0.3em)
    #text(size: 1em, fill: palette.cream)[#subtitle]
  ]
  #v(0.5em)
  #line(length: 30%, stroke: 1pt + palette.white)
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

// ── Apply ──────────────────────────────────────────────────────────────────
// Applied in the deck via `#show: theme.apply`. Deck typography is driven
// entirely by heading level; `base-size` is the single source of truth, and
// heading sizes are absolute multiples of it so they do not compound with
// Mosaic's own em-based heading rules.
#let apply(body, font: "Inter", base-size: 18pt) = {
  show: setup.with(
    colors: colors,
    spacing: (inset: 0pt),
    auto-slide: default-layout,
  )
  set text(font: font, size: base-size)
  // Markup lists are "tight" by default, which packs bullets at line
  // leading. Rebuild them loose so items breathe without per-slide tuning.
  show list.where(tight: true): it => list(tight: false, ..it.children)
  show enum.where(tight: true): it => enum(tight: false, ..it.children)
  set list(spacing: 0.9em)
  set enum(spacing: 0.9em)
  show heading.where(level: 1): set text(size: base-size * 1.9, weight: "bold")
  show heading.where(level: 2): set text(size: base-size * 1.25, weight: "bold")
  show heading: set block(below: 0.5em)
  body
}

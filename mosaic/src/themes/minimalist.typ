// Minimalist White: cream and red, Source Serif 4. A bundled Mosaic theme.
//
// Use it from the package namespace:
//   #import "@local/mosaic:0.0.1" as m
//   #show: m.themes.minimalist.apply
//   #m.themes.minimalist.title([My talk], subtitle: [A subtitle])
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
  cream: rgb("#fffcf9"),
  red: rgb("#c83224"),
)

#let colors = (
  canvas: palette.cream,
  surface: palette.cream,
  accent: palette.red,
  text: palette.red,
  inverse-text: palette.cream,
  muted: palette.red,
  line: palette.red,
)

// ── Layouts ────────────────────────────────────────────────────────────────
// The ordinary content slide: a quiet cream page (the page canvas) with the
// heading and body stacked top-left. Registered as `auto-slide` in `apply`,
// so plain `== Title` markup renders through it. Override its look per slide
// with scoped native rules around the call, targeting
// `<mosaic-cell-content>`.
#let default-layout(title, body) = slide(
  grid: grid.cell("content", inset: 45pt),
)[
  #title
  #body
]

// Opening slide in the style of the deck's cover: a large bold serif title at
// left-horizon and a thin red rule near the bottom edge. `authors` takes an
// array of `mosaic.author(...)` records; only the names are shown.
#let title-layout(
  title,
  subtitle: none,
  authors: (),
  date: none,
) = slide(
  grid: grid.cell("cover", inset: 45pt),
  foreground: place(bottom + left, dx: 45pt, dy: -45pt)[
    #line(length: 100% - 90pt, stroke: 1pt + palette.red)
  ],
)[
  #text(size: 2.79em, weight: "bold")[#title]
  #if subtitle != none [
    #v(0.3em)
    #text(size: 1.29em)[#subtitle]
  ]
  #if authors.len() > 0 or date != none [
    #v(1.4em)
    #text(size: 0.93em)[
      #authors.map(author => author.name).join(", ")
      #if authors.len() > 0 and date != none [ · ]
      #date
    ]
  ]
]

// Section-divider slide: one centered serif sentence, as in the deck's
// interstitial pages.
#let section-layout(title, subtitle: none) = slide(
  grid: grid.cell("section"),
  section: true,
)[
  #text(size: 1.79em, weight: "bold")[#title]
  #if subtitle != none [
    #v(0.3em)
    #text(size: 1em)[#subtitle]
  ]
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
// Applied in the deck via `#show: theme.apply`. Heading sizes are absolute
// (`base-size * factor`) so they do not compound with Mosaic's own em-based
// heading rules.
#let apply(body, font: "Source Serif 4", base-size: 14pt) = {
  show: setup.with(
    colors: colors,
    spacing: (inset: 0pt),
    auto-slide: default-layout,
  )
  set text(font: font, fill: palette.red, size: base-size)
  // Markup lists are "tight" by default, which packs bullets at line
  // leading. Rebuild them loose so items breathe without per-slide tuning.
  show list.where(tight: true): it => list(tight: false, ..it.children)
  show enum.where(tight: true): it => enum(tight: false, ..it.children)
  set list(spacing: 0.9em)
  set enum(spacing: 0.9em)
  show heading.where(level: 1): set text(size: base-size * 2.2, weight: "bold")
  show heading.where(level: 2): set text(size: base-size * 1.79, weight: "bold")
  show heading: set block(below: 0.6em)
  // Cell styling is native: cells are blocks labeled <mosaic-cell-ID>. The
  // cover anchors at left-horizon; section dividers reset setup's display
  // typography (absolute size, since em sizes compound across nested rules)
  // and keep the centered default.
  show label("mosaic-cell-cover"): set align(horizon)
  show label("mosaic-cell-section"): set text(
    size: base-size,
    weight: "regular",
  )
  body
}

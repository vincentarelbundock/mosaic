// Grayscale: a single-file Mosaic theme (black, white, and gray, Inter). It
// powers the Photojournalist Portfolio example deck.
//
// Every Mosaic theme module follows the same convention. It imports only
// Mosaic and exports:
//   - `apply`, the document wrapper applied with `#show: theme.apply`,
//   - `default`, `title`, and `section`, the semantic layout factories,
//     also grouped in the `layouts` dictionary; `default` is registered as
//     `auto-slide` so plain `== Title` markup renders through it,
//   - `colors`, the semantic Mosaic color roles,
//   - `palette`, the theme's raw design tokens.
// Copy this file next to your deck and `#import "theme.typ" as theme`.
#import "@local/mosaic:0.0.1" as m

// ── Palette ────────────────────────────────────────────────────────────────
#let ink = rgb("#111111")
#let paper = rgb("#f7f7f5")
#let gray = rgb("#d9d9d9")
#let sans = "Inter"
#let small-copy = 11pt
#let body-copy = 13pt

#let palette = (
  ink: ink,
  paper: paper,
  gray: gray,
)

#let colors = (
  canvas: paper,
  surface: paper,
  accent: ink,
  text: ink,
  inverse-text: white,
  muted: rgb("#666666"),
  line: gray,
)

// A solid black band with white text, the deck's signature surface.
#let black-panel(body, inset: 20pt) = block(
  width: 100%,
  fill: ink,
  inset: inset,
  text(fill: white, body),
)

// ── Layouts ────────────────────────────────────────────────────────────────
// The ordinary content slide: a paper page with a bold heading over a thin
// gray rule, body below. Registered as `auto-slide` in `apply`, so plain
// `== Title` markup renders through it. `cell-styles` is forwarded so decks
// can override the theme's defaults per slide.
#let default-layout(title, body, cell-styles: (:)) = m.slide(
  grid: m.grid.cell("content"),
  cell-styles: (
    content: (fill: paper, inset: 40pt, align: top + left),
  ) + cell-styles,
)[
  #title
  #line(length: 100%, stroke: 0.6pt + gray)
  #v(0.8em)
  #body
]

// Opening slide: an ink field with a bold white title at left-horizon over a
// short gray rule, the subtitle and byline in quiet gray beneath. `authors`
// takes an array of `m.author(...)` records; only the names are shown.
#let title-layout(
  title,
  subtitle: none,
  authors: (),
  date: none,
  cell-styles: (:),
) = m.slide(
  grid: m.grid.cell("cover"),
  cell-styles: (
    cover: (fill: ink, inset: 45pt, align: left + horizon),
  ) + cell-styles,
)[
  #text(size: 44pt, weight: "bold", fill: white)[#title]
  #v(0.5em)
  #line(length: 25%, stroke: 1pt + gray)
  #if subtitle != none [
    #v(0.5em)
    #text(size: 17pt, fill: gray)[#subtitle]
  ]
  #if authors.len() > 0 or date != none [
    #v(1.8em)
    #text(size: small-copy, fill: white)[
      #authors.map(author => author.name).join(", ")
      #if authors.len() > 0 and date != none [ · ]
      #date
    ]
  ]
]

// Section-divider slide: a black band on the left third of the page, the rest
// left as paper margin.
#let section-layout(title, subtitle: none, cell-styles: (:)) = m.slide(
  grid: m.grid.h(
    m.grid.t(0.38fr, m.grid.cell("band")),
    m.grid.t(0.62fr, m.grid.cell("rest", content: [])),
  ),
  section: true,
  cell-styles: (
    band: (fill: ink, inset: 28pt, align: left + horizon),
    rest: (fill: paper),
  ) + cell-styles,
)[
  #text(size: 30pt, weight: "bold", fill: white)[#title]
  #if subtitle != none [
    #v(0.4em)
    #text(size: 15pt, fill: gray)[#subtitle]
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
// Applied in the deck via `#show: theme.apply`. Show/set rules cannot cross
// an `#import`, so the document-wide styling lives in this wrapper rather
// than at the top level of the file.
#let apply(body) = {
  show: m.setup.with(
    colors: colors,
    spacing: (inset: 0pt),
    auto-slide: default-layout,
  )
  set text(font: sans, size: body-copy, fill: ink)
  // Markup lists are "tight" by default, which packs bullets at line leading.
  // Rebuild them loose so items breathe without per-slide tuning.
  show list.where(tight: true): it => list(tight: false, ..it.children)
  show enum.where(tight: true): it => enum(tight: false, ..it.children)
  set list(spacing: 0.9em)
  set enum(spacing: 0.9em)
  show heading: set text(weight: "bold")
  body
}

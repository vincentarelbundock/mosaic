// A complete Mosaic theme in one file, followed by the deck that uses it.
// A theme is ordinary Typst: a palette, layout factories that return
// `m.slide(...)`, and an `apply` wrapper that hands deck-wide settings to
// `setup` and paints the structural cells with native rules.
#import "@local/mosaic:0.0.1" as m

// 1 — The palette: plain values, no registry.
#let navy = rgb("#1f2a44")
#let gold = rgb("#d9a441")
#let mist = rgb("#f4f1ea")

// 2 — The ordinary content slide. Registered as `auto-slide` below, so
// plain `== Title` markup renders through it.
#let default(title, body) = m.slide(
  grid: m.layouts.default(variant: "header-body"),
)[#title][#body]

// 3 — Layout factories for the cover and the section dividers. The grids are
// purely structural; their look lives in `apply` as label rules.
#let title(title, subtitle: none) = m.slide(
  grid: m.grid.cell("cover", inset: 3em),
)[
  #text(size: 2.4em, weight: "bold", fill: mist)[#title]
  #v(0.3em)
  #text(size: 1.2em, fill: gold)[#subtitle]
]

#let section(title) = m.slide(
  grid: m.grid.cell("section"),
  section: true,
)[
  #text(size: 1.8em, weight: "bold", fill: navy)[#title]
]

// 4 — The factories grouped for programmatic use (theme switching, tests).
#let layouts = (default: default, title: title, section: section)

// 5 — The wrapper: deck-wide settings flow through `setup`; the cell looks
// are native `show label(...)` rules, and everything else is an ordinary
// `set` or `show` rule.
#let apply(body) = {
  show: m.setup.with(
    colors: (
      canvas: mist,
      surface: mist,
      accent: gold,
      text: navy,
      inverse-text: mist,
      muted: navy.lighten(35%),
      line: navy,
    ),
    features: (slide-number: true),
    auto-slide: default,
  )
  set text(size: 20pt)
  // Rebuild "tight" markup lists loose so bullets breathe by default.
  show list.where(tight: true): it => list(tight: false, ..it.children)
  set list(spacing: 0.9em)
  // The cover: a full navy field with left-aligned content.
  show label("mosaic-cell-cover"): set align(left + horizon)
  show label("mosaic-cell-cover"): it => block(
    width: 100%,
    height: 100%,
    fill: navy,
    it,
  )
  // The section divider: a centered gold field. Reset setup's display size
  // (absolute, so it does not compound with nested rules).
  show label("mosaic-cell-section"): set align(center + horizon)
  show label("mosaic-cell-section"): set text(size: 20pt)
  show label("mosaic-cell-section"): it => block(
    width: 100%,
    height: 100%,
    fill: gold,
    it,
  )
  body
}

// ── The deck ───────────────────────────────────────────────────────────
#show: apply

#title(
  [A starter theme],
  subtitle: [Fifty lines of ordinary Typst],
)

== The whole theme fits on one screen

#m.reveal[
  - The palette is a handful of `#let` bindings.
  - Layout factories are functions that return `m.slide(...)`.
  - The `apply` wrapper passes deck-wide settings to `setup` and paints the
    cells with native rules.
]

#section[That is all there is]

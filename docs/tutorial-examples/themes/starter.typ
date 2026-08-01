// A complete Mosaic theme in one file, followed by the deck that uses it.
// A theme is ordinary Typst: a palette, layout factories that return
// `m.slide(...)`, and an `apply` wrapper that hands deck-wide settings to
// `setup`.
#import "@local/mosaic:0.0.1" as m

// 1 — The palette: plain values, no registry.
#let navy = rgb("#1f2a44")
#let gold = rgb("#d9a441")
#let mist = rgb("#f4f1ea")

// 2 — The ordinary content slide. Registered as `auto-slide` below, so
// plain `== Title` markup renders through it.
#let default(title, body, cell-styles: (:)) = m.slide(
  grid: m.layouts.default(variant: "header-body"),
  cell-styles: cell-styles,
)[#title][#body]

// 3 — Layout factories for the cover and the section dividers.
#let title(title, subtitle: none) = m.slide(
  grid: m.grid.cell("cover"),
  cell-styles: (cover: (fill: navy, inset: 3em, align: left + horizon)),
)[
  #text(size: 2.4em, weight: "bold", fill: mist)[#title]
  #v(0.3em)
  #text(size: 1.2em, fill: gold)[#subtitle]
]

#let section(title) = m.slide(
  grid: m.grid.cell("section"),
  section: true,
  cell-styles: (section: (fill: gold, align: center + horizon)),
)[
  #text(size: 1.8em, weight: "bold", fill: navy)[#title]
]

// 4 — The factories grouped for programmatic use (theme switching, tests).
#let layouts = (default: default, title: title, section: section)

// 5 — The wrapper: deck-wide settings flow through `setup`; everything
// else is a native `set` or `show` rule.
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
  - The `apply` wrapper passes deck-wide settings to `setup`.
]

#section[That is all there is]

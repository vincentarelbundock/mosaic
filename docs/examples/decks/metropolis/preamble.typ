// Deck-specific preamble for the Metropolis technical deck. The reusable look
// is the bundled Metropolis theme (m.themes.metropolis); theme.typ re-exports
// it as `m` together with this deck's visual constants; importing with `*`
// re-exports everything to main.typ. This file adds the helpers that belong
// to this deck's content rather than to the theme:
//   - fletcher  : node/edge diagrams (the state machine)
//   - cetz      : general vector drawing (the Bloch sphere)
//   - calepin   : executes embedded R chunks at compile time and caches results
#import "theme.typ": *
#import "@preview/fletcher:0.5.8" as fletcher
#import "@preview/cetz:0.5.2"
#import "/.calepin/calepin.typ" as calepin

// Accent colors used to tint individual terms in the Bellman equation.
#let blue = rgb("#2563eb")
#let green = rgb("#15803d")
#let red = rgb("#c2410c")

// ── Inline content helpers ─────────────────────────────────────────────────
// Small building blocks used *inside* a slide body rather than whole slides.
#let code(body) = text(font: mono, size: 0.65em, body)
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

// `m.steps.reduce` wraps a drawing package so that elements guarded by `m.steps.on("2-",
// ...)` appear across successive reveals. `hide` keeps hidden elements in the
// layout (reserving their space) so nothing shifts as the diagram is built up.
#let state-diagram = m.steps.reduce.with(
  render: fletcher.diagram,
  hide: fletcher.hide,
)

#let canvas = m.steps.reduce.with(
  render: cetz.canvas,
  hide: cetz.draw.hide.with(bounds: true),
)

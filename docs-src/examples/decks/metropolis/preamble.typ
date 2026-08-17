// Deck-specific preamble for the Metropolis technical deck. The look is the
// bundled Metropolis theme, imported bare; this file adds only the helpers
// that belong to this deck's content rather than to the theme:
//   - fletcher  : node/edge diagrams (the state machine)
//   - cetz      : general vector drawing (the Bloch sphere)
#import "@preview/mosaic:0.0.1" as mosaic
#import mosaic.themes.metropolis as m
#import "@preview/fletcher:0.5.8" as fletcher
#import "@preview/cetz:0.5.2"

// Diagram colors: the theme's ink for structural marks, and three accents
// used to tint individual terms in the Bellman equation.
#let ink = rgb("#23373b")
#let blue = rgb("#2563eb")
#let green = rgb("#15803d")
#let red = rgb("#c2410c")

// Fixed-footprint annotations prevent incremental underbraces from moving
// neighboring terms or changing the equation's baseline.
#let dstrut = context { hide($j$) + h(-measure($j$).width) }
#let explained(color, term, label) = context {
  let braced = text(fill: color, $underbrace(#term #dstrut, #label)$)
  box(height: measure(text(fill: color, $#term$)).height, braced)
}

// `m.steps.drawing` wraps a drawing package so that elements guarded by
// `m.steps.on("2-", ...)` appear across successive reveals. `hide` keeps
// hidden elements in the layout (reserving their space) so nothing shifts as
// the diagram is built up.
#let state-diagram = m.steps.drawing.with(
  render: fletcher.diagram,
  hide: fletcher.hide,
)

#let canvas = m.steps.drawing.with(
  render: cetz.canvas,
  hide: cetz.draw.hide.with(bounds: true),
)

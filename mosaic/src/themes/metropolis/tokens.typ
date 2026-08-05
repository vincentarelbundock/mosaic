// Metropolis design tokens.
// `colors` is this theme's stable palette export: one flat dictionary holding
// the six deck colors and the two status colors. The named constants above it
// are private mixing values: a derived theme should extend `colors`, never
// reach for them by name.
#let ink = rgb("#23373b")
#let orange = rgb("#f28e2b")
#let paper = rgb("#fafafa")
#let dot = rgb("#667477")
#let track = rgb("#b8b1a8")
#let colors = (
  canvas: paper,
  surface: paper,
  text: ink,
  muted: dot,
  line: track,
  accent: orange,
  warning: rgb("#E69F00"),
  error: rgb("#D55E00"),
)

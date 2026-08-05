// Minimalist design tokens.
// `colors` is this theme's stable palette export: one flat dictionary holding
// the six deck colors and the two status colors. The named constants above it
// are private mixing values: a derived theme should extend `colors`, never
// reach for them by name.
#let cream = rgb("#fffcf9")
#let red = rgb("#c83224")
#let colors = (
  canvas: cream,
  surface: cream,
  text: red,
  muted: red,
  line: red,
  accent: red,
  warning: rgb("#E69F00"),
  error: rgb("#D55E00"),
)

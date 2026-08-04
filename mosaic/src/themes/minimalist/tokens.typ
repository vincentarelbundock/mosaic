// Minimalist design tokens.
// `colors` is this theme's stable palette export and carries exactly the six
// canonical roles. The named constants above it are private mixing values:
// a derived theme should extend `colors`, never reach for them by name.
#let cream = rgb("#fffcf9")
#let red = rgb("#c83224")
#let colors = (
  canvas: cream,
  surface: cream,
  text: red,
  muted: red,
  line: red,
  accent: red,
)

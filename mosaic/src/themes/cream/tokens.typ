// Cream design tokens.
// `colors` is this theme's stable palette export and carries exactly the six
// canonical roles. The named constants above it are private mixing values:
// a derived theme should extend `colors`, never reach for them by name.
#let sage = rgb("#aebdb3")
#let cream = rgb("#f2eee5")
#let ink = rgb("#111111")
#let white = rgb("#f9f8f3")
#let colors = (
  canvas: sage,
  surface: cream,
  text: ink,
  muted: ink,
  line: ink,
  accent: ink,
)

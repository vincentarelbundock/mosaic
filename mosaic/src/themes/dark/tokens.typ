// Private Dark theme design tokens.
// `colors` is this theme's stable palette export: one flat dictionary holding
// the six deck colors and the three status colors. The named constants above it
// are private mixing values: a derived theme should extend `colors`, never
// reach for them by name.
//
// Dark states no component palette of its own. Components tint their panel
// fills into `canvas`, so the same rule that produces pale washes on a light
// deck produces deep ones here.
#let canvas = rgb("#0d1117")
#let surface = rgb("#161b22")
#let text = rgb("#e6edf3")
#let muted = rgb("#8b949e")
#let accent = rgb("#58a6ff")
#let attention = rgb("#d29922")
#let error = rgb("#ff7b72")
#let line = rgb("#30363d")
#let colors = (
  canvas: canvas,
  surface: surface,
  accent: accent,
  text: text,
  muted: muted,
  line: line,
  warning: attention,
  error: error,
)

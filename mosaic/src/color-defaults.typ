// Private color constants for Mosaic's default page, typography, furniture,
// and drawn layout decoration. These preserve the former default light look
// without exposing semantic color state.
#let default-canvas = rgb("#fafaf9")
#let default-surface = white
#let default-accent = rgb("#2563eb")
#let default-text = rgb("#1c1917")
#let default-muted = rgb("#78716c")
#let default-line = rgb("#e7e5e4")
// The built-in light palette, exported as one value so a custom theme can
// extend or replace it as a unit rather than copying six constants:
//
//   colors: mosaic.theme.light-palette + (accent: rgb("#b91c1c"))
//
#let light-palette = (
  canvas: default-canvas,
  surface: default-surface,
  accent: default-accent,
  text: default-text,
  muted: default-muted,
  line: default-line,
)

#let default-colors = light-palette

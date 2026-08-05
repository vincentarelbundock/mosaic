// Private color constants for Mosaic's default page, typography, furniture,
// and drawn layout decoration. These preserve the former default light look
// without exposing semantic color state.
//
// The built-in light palette, exported as one value so a custom theme can
// extend or replace it as a unit rather than copying six constants:
//
//   colors: mosaic.theme.light-palette + (accent: rgb("#b91c1c"))
//
#let light-palette = (
  canvas: rgb("#fafaf9"),
  surface: white,
  accent: rgb("#2563eb"),
  text: rgb("#1c1917"),
  muted: rgb("#78716c"),
  line: rgb("#e7e5e4"),
)

// The drawn-rule color, imported alone where the palette as a whole would
// overreach.
#let default-line = light-palette.line

#let default-colors = light-palette

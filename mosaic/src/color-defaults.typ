// Private color constants for Mosaic's default page, typography, furniture,
// and drawn layout decoration. These preserve the former default light look
// without exposing semantic color state.
//
// The palette is one flat dictionary of single colors. Six of them are the
// deck's own chrome (`canvas` through `accent`); the remaining two name the
// status colors components paint with. A component derives its panel fill by
// mixing its color into `canvas`, so a palette states each color once and the
// tint follows the theme in both light and dark directions.
//
// The built-in light palette, exported as one value so a custom theme can
// extend or replace it as a unit rather than copying constants:
//
//   colors: mosaic.themes.light-palette + (accent: rgb("#b91c1c"))
//
// The status pair is drawn from the Okabe-Ito colorblind-safe set.
#let light-palette = (
  canvas: rgb("#fafaf9"),
  surface: white,
  accent: rgb("#2563eb"),
  text: rgb("#1c1917"),
  muted: rgb("#78716c"),
  line: rgb("#e7e5e4"),
  warning: rgb("#E69F00"),
  error: rgb("#D55E00"),
)

// The drawn-rule color, imported alone where the palette as a whole would
// overreach.
#let default-line = light-palette.line

#let default-colors = light-palette

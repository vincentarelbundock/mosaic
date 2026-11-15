#import "@local/mosaic:0.0.3" as mosaic
// `font` was a per-theme option; it is a setup option a theme presets.
#let setup = mosaic.themes.setup((
  colors: (canvas: white, surface: white, accent: blue, text: black, muted: gray, line: gray, warning: orange, error: red),
  options: (font: "Inter"),
))
Body

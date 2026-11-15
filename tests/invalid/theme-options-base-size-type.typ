#import "@local/mosaic:0.0.3" as mosaic
// Bound, never applied: the two options the engine reads are checked early.
#let setup = mosaic.themes.setup((
  colors: (canvas: white, surface: white, accent: blue, text: black, muted: gray, line: gray, warning: orange, error: red),
  options: (base-size: "big"),
))
Body

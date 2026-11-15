#import "@local/mosaic:0.0.3" as mosaic
// Bound, never applied: the definition fails where the setup is built.
#let setup = mosaic.themes.setup((
  colors: (canvas: white, surface: white, accent: blue, text: black, muted: gray, line: gray, warning: orange, error: red),
  defaults: (mystery: 1),
))
Body

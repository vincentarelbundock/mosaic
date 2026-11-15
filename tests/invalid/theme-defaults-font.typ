#import "@local/mosaic:0.0.3" as mosaic
// A theme states its font under `options`; `defaults` holds setup options.
#let setup = mosaic.themes.setup((
  colors: (canvas: white, surface: white, accent: blue, text: black, muted: gray, line: gray, warning: orange, error: red),
  defaults: (font: "Inter"),
))
Body

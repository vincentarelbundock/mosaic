#import "@local/mosaic:0.0.3" as mosaic
// Bound, never applied: the definition fails where the setup is built.
#let setup = mosaic.themes.setup((colors: (canvas: white, text: black)))
Body

#import "@local/mosaic:0.0.1" as mosaic
#let custom = (
  colors: (
    canvas: white,
    surface: luma(245),
    accent: blue,
    text: black,
    muted: gray,
    line: luma(180),
  ),
  layouts: (content: mosaic.layouts.content()),
)
#show: mosaic.theme.setup(custom)
Body

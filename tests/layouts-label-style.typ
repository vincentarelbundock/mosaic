#import "@local/mosaic:0.0.2" as mosaic
#show: mosaic.setup
#show label("mosaic-cell-body"): set text(fill: rgb("#fedcba"))
#show label("mosaic-cell-body"): mosaic.surface(fill: rgb("#123456"), height: 100%)
// Planes have dedicated labels, so native rules style them directly.
#show label("mosaic-background"): set text(fill: rgb("#77aa11"))
#mosaic.slide(
  layout: mosaic.layouts.content(variant: "body"),
  background: place(bottom + left)[Styled plane],
)[Styled layout]

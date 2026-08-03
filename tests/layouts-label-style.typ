#import "@local/mosaic:0.0.1" as mosaic
#show: mosaic.setup
#show label("mosaic-cell-body"): set text(fill: rgb("#fedcba"))
#show label("mosaic-cell-body"): mosaic.surface(fill: rgb("#123456"))
// Planes carry the same label vocabulary as cells, so native rules style them.
#show label("mosaic-cell-background"): set text(fill: rgb("#77aa11"))
#mosaic.slide(
  layout: mosaic.layouts.content(variant: "body"),
  content: (background: place(bottom + left)[Styled plane]),
)[Styled layout]

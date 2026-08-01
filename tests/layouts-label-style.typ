#import "@local/mosaic:0.0.1" as mosaic
#show: mosaic.setup
#show label("mosaic-cell-body"): set text(fill: rgb("#fedcba"))
#show label("mosaic-cell-body"): it => block(
  width: 100%,
  height: 100%,
  fill: rgb("#123456"),
  it,
)
#mosaic.slide(grid: mosaic.layouts.default(variant: "body"))[Styled layout]

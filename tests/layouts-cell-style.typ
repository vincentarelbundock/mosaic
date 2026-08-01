#import "@local/mosaic:0.0.1" as mosaic
#show: mosaic.setup
#mosaic.slide(
  grid: mosaic.layouts.default(
    variant: "body",
    fill: (body: rgb("#123456")),
    text: (body: (fill: rgb("#fedcba"))),
    inset: (body: 20pt),
  ),
)[Styled layout]

#import "@local/mosaic:0.0.1" as m

#let grid = m.grid.cell("body")

#show: m.setup.with(
  colors: (canvas: rgb("#f4f1ea")),
)
#set text(size: 22pt, fill: rgb("#172033"))

#m.slide(
  grid,
  cell-styles: (body: (inset: 2em, align: right + horizon)),
  background: m.image(
    path("/docs/assets/images/bonsai.webp"),
    lighten: 35%,
    alt: "A pine bonsai",
  ),
)[
  #block(width: 38%)[
    == A background image

    Pass `m.image()` content through `background:`.
  ]
]

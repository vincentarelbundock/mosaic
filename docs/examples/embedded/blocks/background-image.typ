#import "@local/mosaic:0.0.1" as m

#let grid = m.grid.cell("body", inset: 2em)

#show: m.setup
#set page(fill: rgb("#f4f1ea"))
#set text(size: 22pt, fill: rgb("#172033"))

// Anchor the body content to the right, past the image, through its label.
#show label("mosaic-cell-body"): set align(right + horizon)

#m.slide(layout: 
  grid,
  content: (background: m.components.image(
    path("/docs/assets/images/bonsai.webp"),
    lighten: 35%,
    alt: "A pine bonsai",
  )),
)[
  #block(width: 38%)[
    == A background image

    Pass `m.components.image()` content through the `background` entry.
  ]
]

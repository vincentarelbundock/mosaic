#import "@preview/mosaic:0.0.1" as m

#show: m.setup
#set page(fill: rgb("#f4f1ea"))
#set text(size: 22pt, fill: rgb("#172033"))

// Anchor the body content to the right, past the image, through its label.
#show label("mosaic-cell-body"): set align(right + horizon)

#m.slide(
  "content",
  variant: "body",
  background: m.components.image(
  path("/docs/assets/images/bonsai.webp"),
  scrim: white.transparentize(65%),
  alt: "A pine bonsai",
),
)[
  #block(width: 38%)[
    == A background image

    Pass `m.components.image()` content through the `background` entry.
  ]
]

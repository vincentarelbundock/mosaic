#import "@preview/mosaic:0.0.1" as m

#show: m.setup
#set page(fill: rgb("#f4f1ea"))
#set text(size: 22pt, fill: rgb("#172033"))

#m.slide(layout: m.grids.columns("a", "b"))[
  #m.components.figure(
    path("/docs-src/assets/images/bonsai.webp"),
    caption: [Figure in a cell.],
    alt: "A pine bonsai",
  )
][
  == Figures fit their cell

  `m.components.figure(..)` contains the picture, centres it, and leaves the caption exactly the height it needs.
]

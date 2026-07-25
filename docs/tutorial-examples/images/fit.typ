#import "@local/mosaic:0.0.1" as m

#show: m.setup

#m.slide(
  m.grid.h(
    m.grid.cell("a"),
    m.grid.cell("b"),
  ),
  cell-styles: (
    a: (stroke: 3pt + rgb("#e69f00")),
    b: (stroke: 3pt + rgb("#e69f00")),
  ),
)[
  #m.image(
    path("/docs/assets/images/dog.webp"),
    alt: "A brown dog",
  )
][
  #m.image(
    path("/docs/assets/images/dog.webp"),
    fit: "contain",
    alt: "A brown dog",
  )
]

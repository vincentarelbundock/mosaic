#import "@local/mosaic:0.0.1" as m

#show: m.setup

// Frame both image cells by targeting their labels with a native stroke.
#let framed(id) = it => {
  show label("mosaic-cell-" + id): body => block(
    width: 100%,
    height: 100%,
    stroke: 3pt + rgb("#e69f00"),
    body,
  )
  it
}
#show: framed("a")
#show: framed("b")

#m.slide(layout: 
  m.grid.h(
    m.grid.cell("a"),
    m.grid.cell("b"),
  ),
)[
  #m.components.image(
    path("/docs/assets/images/dog.webp"),
    alt: "A brown dog",
  )
][
  #m.components.image(
    path("/docs/assets/images/dog.webp"),
    fit: "contain",
    alt: "A brown dog",
  )
]

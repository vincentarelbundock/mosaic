#import "@local/mosaic:0.0.1" as m

#show: m.setup
#set page(fill: rgb("#f4f1ea"))
#set text(size: 22pt, fill: rgb("#172033"))

#m.slide(layout: m.grid.h("a", "b"))[
  #figure(
    m.components.image(
      path("/docs/assets/images/bonsai.webp"),
      width: 100%,
      height: 10.2em,
      fit: "contain",
      alt: "A pine bonsai",
    ),
    caption: [Figure in a cell.],
  )
][
  == Figures remain native

  Use `figure(m.components.image(...), caption: ...)` for captions, numbering, and references.
]

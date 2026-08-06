#import "@preview/mosaic:0.0.1" as m
#import "_title-info.typ": info

#show: m.setup.with(..info)

#m.slide(
  numbered: false,
  background: m.components.image(
    path("/docs/assets/images/title-city.webp"),
    scrim: black.transparentize(80%),
    alt: "Coastal city lights at night",
  ),
  // One cell for the whole slide; the two stacks are placed inside it.
  layout: m.grids.cell(id: "cover"),
)[
  #set text(fill: white)
  // m.info() is contextual, so it has to be read inside a context block.
  #context {
    let deck = m.info()
    place(top + left, {
      text(size: 1.9em, weight: "bold", deck.title)
      block(
        above: 0.9em,
        text(size: 1.05em, fill: white.transparentize(20%), deck.subtitle),
      )
    })
    place(bottom + left, {
      set par(leading: 0.5em)
      text(weight: "medium", deck.authors.map(author => author.name).join([, ]))
      linebreak()
      text(size: 0.75em, fill: white.transparentize(20%), deck.date)
    })
  }
]

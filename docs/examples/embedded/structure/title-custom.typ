#import "@local/mosaic:0.0.1" as m
#import "_title-info.typ": info

#show: m.setup.with(..info)

// A hand-built cover: a full-slide photograph on the background plane, the
// heading anchored to the top edge, and the byline to the bottom, which no
// built-in variant draws. The deck's own metadata comes back through
// m.deck(), so nothing is restated.
#m.slide(
  numbered: false,
  background: m.components.image(
    path("/docs/assets/images/title-city.webp"),
    scrim: black.transparentize(80%),
    alt: "Coastal city lights at night",
  ),
  layout: m.grids.cell(id: "cover"),
)[
  #set text(fill: white)
  #context {
    let deck = m.deck()
    place(top + left, {
      text(size: 2.2em, weight: "bold", deck.title)
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

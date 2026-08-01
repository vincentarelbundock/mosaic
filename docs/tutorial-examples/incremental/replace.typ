#import "@local/mosaic:0.0.1" as m

#show: m.setup
#set text(size: 22pt)

#m.deck(default-grid: m.grid.cell("body", inset: 1.5em))
#let slide = m.slide

#let card(fill, stroke, word) = block(
  width: 20em,
  inset: 1em,
  radius: 0.4em,
  fill: fill,
  stroke: 0.8pt + stroke,
)[
  #set text(size: 1.25em)
  The evidence is *#word.*
]

#slide[
  == Replace content

  #m.replace(
    align: center + horizon,
    card(rgb("#f7f0dd"), rgb("#d8bd72"), [promising]),
    card(rgb("#e8f1fb"), rgb("#9ab9d8"), [convincing]),
    card(rgb("#e8f5ec"), rgb("#91bea0"), [conclusive]),
  )
]

#import "@preview/mosaic:0.0.1" as m
#show: m.setup

#let colors = (
  rgb("#E69F00"), rgb("#56B4E9"), rgb("#009E73"), rgb("#F0E442"),
  rgb("#0072B2"), rgb("#D55E00"), rgb("#CC79A7"),
).map(color => color.lighten(85%))

// One grid, reused by both slides.
#let two-columns = m.grids.columns(
  m.grids.cell("a"),
  m.grids.cell("b"),
)

// One set of deck-wide fill rules, reused by both slides. Because they are
// defined at the deck level, every slide that uses these cell IDs picks them
// up automatically.
#let fill(id, color) = it => {
  show label("mosaic-cell-" + id): body => block(
    width: 100%,
    height: 100%,
    fill: color,
    body,
  )
  it
}
#show: fill("a", colors.at(5))
#show: fill("b", colors.at(4))

#m.slide(layout: two-columns)[
  *slide 0 cell 0*
][
  *slide 0 cell 1*
]

#m.slide(layout: two-columns)[
  *slide 1 cell 0*
][
  *slide 1 cell 1*
]

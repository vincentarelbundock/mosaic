#import "@local/mosaic:0.0.1" as m
#show: m.setup

#let colors = m.color.palette("okabe-ito", lighten: 85%)

// One grid, reused by both slides.
#let two-columns = m.grid.h(
  m.grid.cell("a"),
  m.grid.cell("b"),
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

#m.slide(two-columns)[
  *slide 0 cell 0*
][
  *slide 0 cell 1*
]

#m.slide(two-columns)[
  *slide 1 cell 0*
][
  *slide 1 cell 1*
]

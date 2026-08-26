#import "@local/mosaic:0.0.2" as m
#show: m.setup

// Deck-wide baseline: one native block rule fills every header cell, and a
// text rule keeps the type legible on it.
#show label("mosaic-cell-header"): set block(fill: rgb("#13294b"))
#show label("mosaic-cell-header"): set text(fill: white)

#m.slide[
  == A deck-wide fill
][
  Every header cell takes the baseline `set block` rule.
]

// A rule scoped inside a block overrides the baseline for exactly the slides
// in the block, following ordinary set-rule precedence.
#[
  #show label("mosaic-cell-header"): set block(fill: rgb("#e84a27"))
  #m.slide[
    == A one-slide override
  ][
    The scoped rule replaces the deck-wide fill instead of painting behind it.
  ]
]

#m.slide[
  == The baseline again
][
  Slides outside the block are untouched.
]

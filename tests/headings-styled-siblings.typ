#import "@local/mosaic:0.0.2" as mosaic

// A styled block after a styled heading keeps its own styles: wrapper
// prefixes are matched by identity, so the body's blue is not swapped for the
// heading's red.
#set page(width: 160pt, height: 90pt, margin: 5pt)
#show: mosaic.setup.with(spacing: (inset: 5pt))
#set text(size: 7pt)

#[
  #set text(fill: rgb("#ff4136"))
  == Styled A
]
#[
  #set text(fill: rgb("#0074d9"))
  STYLED SIBLING BODY
]

#context {
  assert(counter(page).final().first() == 1)
}

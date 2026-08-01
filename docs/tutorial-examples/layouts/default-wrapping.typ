#import "@local/mosaic:0.0.1" as m
#show: m.setup

// Fill the header and footer through their labels; the footer also aligns
// right. Both regions are content-sized, so they grow to fit wrapped text.
#show label("mosaic-cell-header"): it => block(
  width: 100%,
  fill: rgb("#dbeafe"),
  it,
)
#show label("mosaic-cell-footer"): set align(right)
#show label("mosaic-cell-footer"): it => block(
  width: 100%,
  fill: rgb("#fde68a"),
  it,
)

#let myslide = m.slide.with(grid: m.layouts.default())

#myslide[
  == A long title wraps onto another line while its region expands automatically
][
  #lorem(24)
][
  A longer footer also wraps when needed, grows upward, and preserves its usual
  padding and right alignment.
]

#import "@local/mosaic:0.0.1" as m
#show: m.setup
#set page(fill: rgb("#f4f0e8"))
#set text(fill: rgb("#20262d"))

// Invert a cell with ordinary native colors.
#let ink = rgb("#20262d")
#let paper = white
#let invert(id) = it => {
  show label("mosaic-cell-" + id): set text(fill: paper)
  show label("mosaic-cell-" + id): body => block(
    width: 100%,
    fill: ink,
    body,
  )
  it
}
#show: invert("header")
#show: invert("footer")

#let myslide = m.slide.with(
  grid: m.layouts.default(),
)

#myslide[
  == Inverted header and footer
][
  #lorem(36)
][
  Both regions share one pair of ordinary Typst color bindings.
]

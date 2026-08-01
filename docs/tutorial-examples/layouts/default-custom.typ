#import "@local/mosaic:0.0.1" as m

// A reusable custom look is a set of deck-wide rules on the default layout's
// structural cells. Bundle them in one transformer and apply it once.
#let custom(body) = {
  show label("mosaic-cell-header"): it => block(
    width: 100%,
    fill: rgb("#ffe29a"),
    it,
  )
  show label("mosaic-cell-body"): set text(fill: rgb("#243746"))
  show label("mosaic-cell-body"): it => block(
    width: 100%,
    height: 100%,
    fill: rgb("#fff9e8"),
    it,
  )
  show label("mosaic-cell-footer"): set align(right)
  show label("mosaic-cell-footer"): it => block(
    width: 100%,
    fill: gradient.linear(rgb("#ffb703"), rgb("#4cc9f0"), angle: 0deg),
    it,
  )
  body
}

#show: m.setup
#show: custom

#let myslide = m.slide.with(grid: m.layouts.default())

#myslide[
  == First slide
][
  #lorem(36)
][
  Reusable style
]

#myslide[
  == Second slide
][
  #lorem(36)
][
  Same custom grid
]

#import "@local/mosaic:0.0.1" as m
#show: m.setup

// Paint the structural cells with native rules. The body places an image
// behind its content; the footer uses a gradient fill.
#show label("mosaic-cell-header"): it => block(
  width: 100%,
  fill: rgb("#c8def0"),
  it,
)
#show label("mosaic-cell-body"): set text(fill: white)
#show label("mosaic-cell-body"): it => block(
  width: 100%,
  height: 100%,
  clip: true,
  {
    place(top + left, block(
      width: 100%,
      height: 100%,
      m.image(
        path("/docs/assets/images/bonsai.webp"),
        darken: 45%,
        alt: "A pine bonsai",
      ),
    ))
    it
  },
)
#show label("mosaic-cell-footer"): set align(right)
#show label("mosaic-cell-footer"): it => block(
  width: 100%,
  fill: gradient.linear(rgb("#ffb703"), rgb("#4cc9f0"), angle: 0deg),
  it,
)

#let myslide = m.slide.with(grid: m.layouts.default())

#myslide[
  == Gradient and image fills
][
  #lorem(30)
][
  Source: Bonsai
]

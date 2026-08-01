#import "@local/mosaic:0.0.1" as m
#show: m.setup

#let myslide = m.slide.with(
  grid: m.layouts.default(
    fill: (
      header: rgb("#c8def0"),
      footer: gradient.linear(rgb("#ffb703"), rgb("#4cc9f0"), angle: 0deg),
    ),
    background: (
      body: m.image(
        path("/docs/assets/images/bonsai.webp"),
        darken: 45%,
        alt: "A pine bonsai",
      ),
    ),
    text: (body: (fill: white)),
    align: (footer: right),
  ),
)

#myslide[
  == Gradient and image fills
][
  #lorem(30)
][
  Source: Bonsai
]

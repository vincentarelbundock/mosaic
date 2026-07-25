#import "@local/mosaic:0.0.1" as m

#let custom = m.templates.default.with(
  fill: (
    header: rgb("#ffe29a"),
    body: rgb("#fff9e8"),
    footer: gradient.linear(rgb("#ffb703"), rgb("#4cc9f0"), angle: 0deg),
  ),
  text: (body: (fill: rgb("#243746"))),
  align: (footer: right),
)

#show: m.setup

#let myslide = m.slide.with(grid: custom())

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

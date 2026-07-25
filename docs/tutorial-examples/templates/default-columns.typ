#import "@local/mosaic:0.0.1" as m
#show: m.setup

#let myslide = m.slide.with(grid: m.templates.default(
  variant: "header-body",
  columns: 3,
  tracks: (2fr, 1fr, 1fr),
))

#myslide[
  == Weighted columns
][
  #lorem(12)
][
  #lorem(12)
][
  #lorem(12)
]

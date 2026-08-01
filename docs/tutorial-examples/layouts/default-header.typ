#import "@local/mosaic:0.0.1" as m
#show: m.setup

#let myslide = m.slide.with(grid: m.layouts.default(
  variant: "header-body",
))

#myslide[
  == Header and body
][
  #lorem(55)
]

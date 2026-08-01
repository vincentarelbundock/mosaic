#import "@local/mosaic:0.0.1" as m
#show: m.setup

#let myslide = m.slide.with(grid: m.layouts.image(
  variant: "full",
  path: path("/docs/assets/images/dog.webp"),
  alt: "Dog",
))

#myslide()

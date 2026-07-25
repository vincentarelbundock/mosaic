#import "@local/mosaic:0.0.1" as m
#show: m.setup

#let myslide = m.slide.with(grid: m.templates.image(
  variant: "left",
  path: path("/docs/assets/images/dog.webp"),
  alt: "Dog",
  tracks: (2fr, 1fr),
))

#myslide[
  #align(center + horizon)[#lorem(18)]
]

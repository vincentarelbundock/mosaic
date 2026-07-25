#import "@local/mosaic:0.0.1" as m
#show: m.setup

#let picture = m.image(
  path("/docs/assets/images/dog.webp"),
  alt: "Dog",
)
#let myslide = m.slide.with(grid: m.templates.section())
#myslide[Plain section]

#let myslide = m.slide.with(grid: m.templates.section(number: [01]))
#myslide[Numbered section]

#let myslide = m.slide.with(
  grid: m.templates.section(variant: "image-left", image: picture),
)
#myslide[Image-left section]

#let myslide = m.slide.with(
  grid: m.templates.section(variant: "image-right", image: picture),
)
#myslide[Image-right section]

#let myslide = m.slide.with(
  grid: m.templates.section(variant: "image-top", image: picture),
)
#myslide[Image-top section]

#let myslide = m.slide.with(
  grid: m.templates.section(variant: "image-bottom", image: picture),
)
#myslide[Image-bottom section]

#let myslide = m.slide.with(
  grid: m.templates.section(variant: "image-background", image: picture),
)
#myslide[Image-background section]

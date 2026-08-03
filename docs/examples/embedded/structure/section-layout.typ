#import "@local/mosaic:0.0.1" as m
#show: m.setup

#let picture = m.components.image(
  path("/docs/assets/images/dog.webp"),
  alt: "Dog",
)
#let myslide = m.slide.with(layout: m.layouts.section())
#myslide[Plain section]

#let myslide = m.slide.with(layout: m.layouts.section(number: [01]))
#myslide[Numbered section]

#let myslide = m.slide.with(
  layout: m.layouts.section(variant: "image-left", image: picture),
)
#myslide[Image-left section]

#let myslide = m.slide.with(
  layout: m.layouts.section(variant: "image-right", image: picture),
)
#myslide[Image-right section]

#let myslide = m.slide.with(
  layout: m.layouts.section(variant: "image-top", image: picture),
)
#myslide[Image-top section]

#let myslide = m.slide.with(
  layout: m.layouts.section(variant: "image-bottom", image: picture),
)
#myslide[Image-bottom section]

// The image itself carries the contrast: darken it and switch the section
// cell to light text through its <mosaic-cell-section> label, scoped to this
// slide.
#[
  #show label("mosaic-cell-section"): set text(fill: white)
  #m.slide(layout: m.layouts.section(
    variant: "image-background",
    image: m.components.image(
      path("/docs/assets/images/dog.webp"),
      darken: 45%,
      alt: "Dog",
    ),
  ))[Image-background section]
]

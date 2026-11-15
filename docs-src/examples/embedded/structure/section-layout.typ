#import "@preview/mosaic:0.0.1" as m
#show: m.setup

#let picture = m.components.image(
  path("/docs-src/assets/images/dog.webp"),
  alt: "Dog",
)
#let myslide = m.slide.with("section")
#myslide[Plain section]

#let myslide = m.slide.with(layout: m.layouts.section(number: [01]))
#myslide[Numbered section]

// The designed text variants read the automatic section counter when no
// number is given.
#let myslide = m.slide.with(
  layout: m.layouts.section(variant: "rule", subtitle: [A heavy Vignelli rule]),
)
#myslide[Rule section]

#let myslide = m.slide.with(
  layout: m.layouts.section(variant: "numeral", subtitle: [A ghost numeral]),
)
#myslide[Numeral section]

#let myslide = m.slide.with(
  layout: m.layouts.section(
    variant: "baseline",
    subtitle: [Title and number on one baseline],
  ),
)
#myslide[Baseline section]

#let myslide = m.slide.with(layout: m.layouts.section(variant: "toc"))
#myslide[Toc section]

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
    image: (
      path: path("/docs-src/assets/images/dog.webp"),
      scrim: black.transparentize(55%),
      alt: "Dog",
    ),
  ))[Image-background section]
]

#import "@local/mosaic:0.0.3" as m
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
  layout: m.layouts.section(
    variant: "image",
    position: "left",
    image: picture,
  ),
)
#myslide[Picture on the left]

#let myslide = m.slide.with(
  layout: m.layouts.section(
    variant: "image",
    position: "right",
    image: picture,
  ),
)
#myslide[Picture on the right]

#let myslide = m.slide.with(
  layout: m.layouts.section(
    variant: "image",
    position: "top",
    image: picture,
  ),
)
#myslide[Picture on the top]

#let myslide = m.slide.with(
  layout: m.layouts.section(
    variant: "image",
    position: "bottom",
    image: picture,
  ),
)
#myslide[Picture on the bottom]

// The image itself carries the contrast: darken it and switch the section
// cell to light text through its <mosaic-cell-section> label, scoped to this
// slide.
#[
  #show label("mosaic-cell-section"): set text(fill: white)
  #m.slide(layout: m.layouts.section(
    variant: "image",
    position: "background",
    image: m.components.image(
      path("/docs-src/assets/images/dog.webp"),
      scrim: black.transparentize(55%),
      alt: "Dog",
    ),
  ))[Picture in the background]
]

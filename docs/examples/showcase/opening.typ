// Opening frame of the home-page showcase reel. It is not a documentation
// example: no page embeds it, and the reel is its only consumer.
#import "@preview/mosaic:0.0.1" as m

#show: m.setup

#let typst-logo = box(
  baseline: 0.1em,
  image(path("/docs/assets/typst.svg"), height: 0.72em, alt: "Typst"),
)

// The photograph keeps its right half quiet, so the type sits there at full
// contrast and the slide needs no scrim.
#[
  #show label("mosaic-cell-body"): set align(top + right)
  #m.slide(
    layout: "image",
    variant: "full",
    image: (
      path: path("/docs/assets/images/bonsai.webp"),
      fit: "cover",
      alt: "A bonsai pine on a pale grey field",
    ),
  )[
    #set par(leading: 0.45em)
    #text(size: 1.5em, weight: 500)[Mosaic] \ \
    #text(size: 1.1em, weight: 300)[Create beautiful \ slides with Typst]
  ]
]

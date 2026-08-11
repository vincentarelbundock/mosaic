#import "@local/mosaic:0.0.2" as mosaic

#set page(width: 240pt, height: 160pt, margin: 0pt)

#let defaults = mosaic.components.image(
  path("/docs-src/assets/images/dog.webp"),
  alt: "A brown dog",
)
#assert(defaults.func() == image)
#assert(defaults.at("width") == 100%)
#assert(defaults.at("height") == 100%)
#assert(defaults.at("fit") == "cover")
#assert(defaults.at("alt") == "A brown dog")

#let configured = mosaic.components.image(
  path("/docs-src/assets/images/dog.webp"),
  width: 40pt,
  height: 30pt,
  fit: "contain",
  alt: "A contained brown dog",
  scaling: "smooth",
)
#assert(configured.func() == image)
#assert(configured.at("width") == 40pt)
#assert(configured.at("height") == 30pt)
#assert(configured.at("fit") == "contain")
#assert(configured.at("alt") == "A contained brown dog")
#assert(configured.at("scaling") == "smooth")

// A scrim wraps the picture in a clipped block, so the result is no longer a
// bare image element.
#let scrimmed = mosaic.components.image(
  path("/docs-src/assets/images/dog.webp"),
  scrim: black.transparentize(65%),
  alt: "A darkened brown dog",
)
#assert(scrimmed.func() != image)

// Every Typst paint is accepted, so a white wash and a gradient need no
// separate syntax of their own.
#grid(
  columns: (1fr, 1fr, 1fr),
  scrimmed,
  mosaic.components.image(
    path("/docs-src/assets/images/dog.webp"),
    scrim: white.transparentize(80%),
    alt: "A lightened brown dog",
  ),
  mosaic.components.image(
    path("/docs-src/assets/images/dog.webp"),
    scrim: gradient.linear(
      black.transparentize(100%),
      black.transparentize(20%),
      angle: 90deg,
    ),
    alt: "A brown dog under a gradient scrim",
  ),
)

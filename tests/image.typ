#import "@local/mosaic:0.0.1" as mosaic

#set page(width: 240pt, height: 160pt, margin: 0pt)

#let defaults = mosaic.image(
  path("/docs/assets/images/dog.webp"),
  alt: "A brown dog",
)
#assert(defaults.func() == image)
#assert(defaults.at("width") == 100%)
#assert(defaults.at("height") == 100%)
#assert(defaults.at("fit") == "cover")
#assert(defaults.at("alt") == "A brown dog")

#let configured = mosaic.image(
  path("/docs/assets/images/dog.webp"),
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

#grid(
  columns: (1fr, 1fr),
  mosaic.image(
    path("/docs/assets/images/dog.webp"),
    darken: 35%,
    alt: "A darkened brown dog",
  ),
  mosaic.image(
    path("/docs/assets/images/dog.webp"),
    lighten: 20%,
    alt: "A lightened brown dog",
  ),
)

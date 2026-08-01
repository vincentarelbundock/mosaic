#import "@local/mosaic:0.0.1" as mosaic
#import "support/grid.typ" as grid-test
#import "../mosaic/src/layout-resolver.typ": resolve-layout
#import "../mosaic/src/settings.typ": make-settings

#let settings = make-settings()
#let picture = image(
  "/docs/assets/images/dog.webp",
  alt: "Dog",
  width: 100%,
  height: 100%,
  fit: "contain",
)
#let full = mosaic.layouts.image()
#let full-grid = resolve-layout(full, settings)
#assert(full-grid.kind == "cell")
#assert(grid-test.count(full-grid) == 1)
#assert(grid-test.bodies(full-grid) == 1)
#assert(grid-test.info(full-grid, "image").cell.style.inset == 0pt)

#let path-full-grid = resolve-layout(
  mosaic.layouts.image(
    path: path("/docs/assets/images/dog.webp"),
    alt: "Dog",
  ),
  settings,
)
#assert(type(grid-test.info(path-full-grid, "image").cell.content) == content)
#assert(grid-test.info(path-full-grid, "image").cell.content.func() == image)
#assert(grid-test.bodies(path-full-grid) == 0)

#let figure-grid = resolve-layout(
  mosaic.layouts.image(
    variant: "figure",
    path: path("/docs/assets/images/dog.webp"),
    alt: "Dog",
  ),
  settings,
)
#assert(figure-grid.kind == "cell")
#assert(grid-test.info(figure-grid, "image").cell.style.inset == settings.spacing.inset)
#assert(type(grid-test.info(figure-grid, "image").cell.content) == content)
#assert(grid-test.bodies(figure-grid) == 0)

#let left-grid = resolve-layout(
  mosaic.layouts.image(
    variant: "left",
    path: path("/docs/assets/images/dog.webp"),
    alt: "Dog",
    tracks: (2fr, 1fr),
  ),
  settings,
)
#assert(left-grid.kind == "split")
#assert(left-grid.axis == "width")
#assert(left-grid.tracks == (2fr, 1fr))
#assert(left-grid.children.at(0).id == "image")
#assert(left-grid.children.at(1).id == "body")
#assert(grid-test.info(left-grid, "image").cell.style.inset == 0pt)
#assert(grid-test.info(left-grid, "image").cell.style.radius == 0pt)
#assert(type(grid-test.info(left-grid, "image").cell.content) == content)
#assert(grid-test.info(left-grid, "body").cell.content == none)
#assert(grid-test.bodies(left-grid) == 1)

#let right-grid = resolve-layout(
  mosaic.layouts.image(
    variant: "right",
    path: path("/docs/assets/images/dog.webp"),
    alt: "Dog",
    fit: "stretch",
    tracks: (1fr, 2fr),
  ),
  settings,
)
#assert(right-grid.kind == "split")
#assert(right-grid.axis == "width")
#assert(right-grid.tracks == (1fr, 2fr))
#assert(right-grid.children.at(0).id == "body")
#assert(right-grid.children.at(1).id == "image")
#assert(grid-test.info(right-grid, "image").cell.style.inset == 0pt)
#assert(grid-test.info(right-grid, "image").cell.style.radius == 0pt)
#assert(type(grid-test.info(right-grid, "image").cell.content) == content)
#assert(grid-test.info(right-grid, "body").cell.content == none)
#assert(grid-test.bodies(right-grid) == 1)

#let top-grid = resolve-layout(
  mosaic.layouts.image(
    variant: "top",
    path: path("/docs/assets/images/dog.webp"),
    alt: "Dog",
    tracks: (2fr, 1fr),
  ),
  settings,
)
#assert(top-grid.kind == "split")
#assert(top-grid.axis == "height")
#assert(top-grid.tracks == (2fr, 1fr))
#assert(top-grid.children.at(0).id == "image")
#assert(top-grid.children.at(1).id == "body")
#assert(grid-test.info(top-grid, "image").cell.style.inset == 0pt)
#assert(grid-test.info(top-grid, "image").cell.style.radius == 0pt)
#assert(type(grid-test.info(top-grid, "image").cell.content) == content)
#assert(grid-test.info(top-grid, "body").cell.content == none)
#assert(grid-test.bodies(top-grid) == 1)

#let bottom-grid = resolve-layout(
  mosaic.layouts.image(
    variant: "bottom",
    path: path("/docs/assets/images/dog.webp"),
    alt: "Dog",
    tracks: (1fr, 2fr),
  ),
  settings,
)
#assert(bottom-grid.kind == "split")
#assert(bottom-grid.axis == "height")
#assert(bottom-grid.tracks == (1fr, 2fr))
#assert(bottom-grid.children.at(0).id == "body")
#assert(bottom-grid.children.at(1).id == "image")
#assert(grid-test.info(bottom-grid, "image").cell.style.inset == 0pt)
#assert(grid-test.info(bottom-grid, "image").cell.style.radius == 0pt)
#assert(type(grid-test.info(bottom-grid, "image").cell.content) == content)
#assert(grid-test.info(bottom-grid, "body").cell.content == none)
#assert(grid-test.bodies(bottom-grid) == 1)

#let top-auto = resolve-layout(mosaic.layouts.image(
  variant: "top",
  path: path("/docs/assets/images/dog.webp"),
), settings)
#assert(top-auto.tracks == (1fr, 1fr))

#let bottom-auto = resolve-layout(mosaic.layouts.image(
  variant: "bottom",
  path: path("/docs/assets/images/dog.webp"),
), settings)
#assert(bottom-auto.tracks == (1fr, 1fr))

#let consuming-left = resolve-layout(mosaic.layouts.image(
  variant: "left",
), settings)
#assert(grid-test.bodies(consuming-left) == 2)

#show: mosaic.setup
#mosaic.slide(grid: full)[#picture]
#mosaic.slide(grid: mosaic.layouts.image(
  variant: "figure",
  path: path("/docs/assets/images/dog.webp"),
  alt: "Dog",
))
#mosaic.slide(grid: mosaic.layouts.image(
  variant: "left",
  path: path("/docs/assets/images/dog.webp"),
  alt: "Dog",
  tracks: (2fr, 1fr),
))[Explanation]
#mosaic.slide(grid: mosaic.layouts.image(
  variant: "right",
  path: path("/docs/assets/images/dog.webp"),
  alt: "Dog",
  tracks: (1fr, 2fr),
))[Explanation]
#mosaic.slide(grid: mosaic.layouts.image(
  variant: "top",
  path: path("/docs/assets/images/dog.webp"),
  alt: "Dog",
  tracks: (2fr, 1fr),
))[Explanation]
#mosaic.slide(grid: mosaic.layouts.image(
  variant: "bottom",
  path: path("/docs/assets/images/dog.webp"),
  alt: "Dog",
  tracks: (1fr, 2fr),
))[Explanation]

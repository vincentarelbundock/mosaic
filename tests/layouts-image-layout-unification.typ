#import "@local/mosaic:0.0.1" as mosaic
#import "support/grid.typ" as grid-test
#import "../mosaic/src/layout-resolver.typ": resolve-layout
#import "../mosaic/src/settings.typ": make-settings

#let settings = make-settings()
#let title-image = path("/docs/assets/images/title-river.webp")
#let section-image = path("/docs/assets/images/dog.webp")

#let title-right-command = mosaic.layouts.title(
  [Shared image geometry],
  variant: "image-right",
  image: title-image,
  tracks: (2fr, 3fr),
  subtitle: [Shared geometry],
  authors: (mosaic.author(
    [Vincent Arel-Bundock],
    affiliations: ((id: "mosaic", name: [Mosaic]),),
  ),),
  date: [2026],

)
#let title-right = resolve-layout(title-right-command, settings)
#assert(title-right.kind == "split")
#assert(title-right.axis == "width")
#assert(title-right.tracks == (2fr, 3fr))
#assert(title-right.children.at(0).kind == "cell")
#assert(title-right.children.at(1).id == "image")
#assert(grid-test.count(title-right) == 2)
#assert(grid-test.bodies(title-right) == 0)
#assert(grid-test.info(title-right, "title").cell.content != none)

#let title-bottom = resolve-layout(mosaic.layouts.title(
  [Shared image geometry],
  variant: "image-bottom",
  image: title-image,
  tracks: (3fr, 2fr),
), settings)
#assert(title-bottom.kind == "split")
#assert(title-bottom.axis == "height")
#assert(title-bottom.tracks == (3fr, 2fr))
#assert(title-bottom.children.at(0).kind == "cell")
#assert(title-bottom.children.at(1).id == "image")
#assert(grid-test.count(title-bottom) == 2)
#assert(grid-test.bodies(title-bottom) == 0)

#let section-left-command = mosaic.layouts.section(
  variant: "image-left",
  image: section-image,
  tracks: (2fr, 3fr),
  number: [03],
  subtitle: [Metadata survives composition],
)
#let section-left = resolve-layout(section-left-command, settings)
#assert(section-left.kind == "split")
#assert(section-left.axis == "width")
#assert(section-left.tracks == (2fr, 3fr))
#assert(section-left.children.at(0).id == "image")
#assert(section-left.children.at(1).id == "section")
#assert(grid-test.count(section-left) == 2)
#assert(grid-test.bodies(section-left) == 1)
#assert(grid-test.info(section-left, "section").cell.style.before != none)
#assert(grid-test.info(section-left, "section").cell.style.after != none)

#let section-right = resolve-layout(mosaic.layouts.section(
  variant: "image-right",
  image: section-image,
), settings)
#assert(section-right.axis == "width")
#assert(section-right.tracks == (1fr, 1fr))
#assert(section-right.children.at(0).id == "section")
#assert(section-right.children.at(1).id == "image")
#assert(grid-test.bodies(section-right) == 1)

#let section-top = resolve-layout(mosaic.layouts.section(
  variant: "image-top",
  image: section-image,
  tracks: (2fr, 1fr),
), settings)
#assert(section-top.kind == "split")
#assert(section-top.axis == "height")
#assert(section-top.tracks == (2fr, 1fr))
#assert(section-top.children.at(0).id == "image")
#assert(section-top.children.at(1).id == "section")
#assert(grid-test.bodies(section-top) == 1)

#let section-bottom = resolve-layout(mosaic.layouts.section(
  variant: "image-bottom",
  image: section-image,
), settings)
#assert(section-bottom.axis == "height")
#assert(section-bottom.tracks == (1fr, 1fr))
#assert(section-bottom.children.at(0).id == "section")
#assert(section-bottom.children.at(1).id == "image")
#assert(grid-test.bodies(section-bottom) == 1)

#let section-background = resolve-layout(mosaic.layouts.section(
  variant: "image-background",
  image: section-image,
), settings)
#assert(section-background.kind == "cell")
#assert(section-background.id == "section")
#assert(section-background.style.background != none)
// Structural cells carry no fill or text styles; appearance comes from the
// <mosaic-cell-section> label rules.
#assert(section-background.style.at("fill", default: none) == none)
#assert("text" not in section-background.style)
#assert(grid-test.count(section-background) == 1)
#assert(grid-test.bodies(section-background) == 1)

#show: mosaic.setup
#mosaic.slide(grid: title-right-command)
#mosaic.slide(grid: section-left-command)[Directional sections]

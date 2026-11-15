#import "@local/mosaic:0.0.3" as mosaic

#show: mosaic.setup

#let photo = mosaic.components.image(path("/docs-src/assets/images/dog.webp"))

// The figure variant owns its picture and caption, so the slide supplies only
// the header cell.
#mosaic.slide(
  layout: mosaic.layouts.image(photo),
  cells: (header: [== Figure, no caption]),
)

#mosaic.slide(
  layout: mosaic.layouts.image(photo, caption: [A captioned figure]),
  cells: (header: [== Figure with caption]),
)

// Every directional variant pairs a full-bleed picture with header and body.
#for side in ("left", "right", "top", "bottom") {
  mosaic.slide(
    layout: mosaic.layouts.image(photo, variant: side),
    cells: (header: [== Image #side], body: [Body beside the picture.]),
  )
}

// Directional tracks are two native sizes in visual order.
#mosaic.slide(
  layout: mosaic.layouts.image(photo, variant: "left", tracks: (2fr, 1fr)),
  cells: (header: [== Weighted tracks], body: [Narrow text column.]),
)

// `full` composes into a single body cell with the picture behind it.
#mosaic.slide(
  layout: mosaic.layouts.image(
    (
      path: path("/docs-src/assets/images/dog.webp"),
      scrim: black.transparentize(55%),
    ),
    variant: "full",
  ),
  cells: (body: [== Over the picture]),
)

// An omitted body gives a bare full-bleed slide.
#mosaic.slide(
  layout: mosaic.layouts.image(photo, variant: "full"),
)

// `fit` overrides the per-variant default. It rebuilds the picture, so it
// needs a path; ready-made content states its own fit and is rejected
// (tests/invalid/layouts-image-fit-content.typ).
#let dog = path("/docs-src/assets/images/dog.webp")
#mosaic.slide(
  layout: mosaic.layouts.image(dog, variant: "left", fit: "contain"),
  cells: (header: [== Contained], body: [Uncropped picture.]),
)

// The argument outranks a `fit` key carried by the picture dictionary, and the
// key applies when the argument is left at `auto`.
#import "../mosaic/src/layout/resolver.typ": resolve-layout
#import "../mosaic/src/settings.typ": make-settings
#import "support/grid.typ" as grid-test
#let picture-fit(layout) = {
  let resolved = resolve-layout(layout, make-settings())
  let picture = grid-test.info(resolved, "image").cell.content
  picture.fit
}
#assert(picture-fit(mosaic.layouts.image(dog, variant: "left")) == "cover")
#assert(picture-fit(mosaic.layouts.image(dog, variant: "left", fit: "contain")) == "contain")
#assert(picture-fit(mosaic.layouts.image((path: dog, fit: "contain"), variant: "left")) == "contain")
#assert(
  picture-fit(mosaic.layouts.image(
    (path: dog, fit: "cover"),
    variant: "left",
    fit: "contain",
  )) == "contain",
  message: "an explicit fit: must win over the picture dictionary's fit key",
)
// A string caption is accepted like any other optional content field.
#mosaic.slide(
  layout: mosaic.layouts.image(dog, caption: "A string caption"),
  cells: (header: [== String caption]),
)

// The layout is explicit-only: it is not part of the configurable set that
// setup and themes supply, so a themed facade exposes the same callable.
#context assert(
  mosaic.layouts.image(photo).name == "image",
  message: "image layout must carry its semantic name",
)

// Selection by name: the layout is not configurable through setup, so the
// slide's own named fields are what construct it.
#mosaic.slide(
  layout: "image",
  image: photo,
  caption: [Selected by name],
  cells: (header: [== Named selection]),
)

#mosaic.slide(
  layout: "image",
  variant: "full",
  image: photo,
  cells: (body: [== Named selection, full bleed]),
)

// A scalar track sizes the picture and is side-independent: the same value
// mirrors cleanly across variants, with the companion region taking 1fr.
#for side in ("left", "right", "top", "bottom") {
  mosaic.slide(
    layout: "image",
    variant: side,
    image: photo,
    tracks: 2fr,
    cells: (header: [== Scalar track #side], body: [Companion takes 1fr.]),
  )
}

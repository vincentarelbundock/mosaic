#import "@local/mosaic:0.0.3" as mosaic

#show: mosaic.setup

#let photo = mosaic.components.image(path("/docs-src/assets/images/dog.webp"))

// The `body` position owns its picture and caption, so the slide supplies only
// the header cell.
#mosaic.slide(
  layout: mosaic.layouts.image(photo),
  cells: (header: [== Figure, no caption]),
)

#mosaic.slide(
  layout: mosaic.layouts.image(photo, caption: [A captioned figure]),
  cells: (header: [== Figure with caption]),
)

// Every directional position pairs a full-bleed picture with header and body.
#for side in ("left", "right", "top", "bottom") {
  mosaic.slide(
    layout: mosaic.layouts.image(photo, position: side),
    cells: (header: [== Image #side], body: [Body beside the picture.]),
  )
}

// Directional tracks are two native sizes in visual order.
#mosaic.slide(
  layout: mosaic.layouts.image(photo, position: "left", tracks: (2fr, 1fr)),
  cells: (header: [== Weighted tracks], body: [Narrow text column.]),
)

// `background` composes into a single body cell with the picture behind it.
// A scrim belongs to the picture, so it is stated on `components.image`.
#mosaic.slide(
  layout: mosaic.layouts.image(
    mosaic.components.image(
      path("/docs-src/assets/images/dog.webp"),
      scrim: black.transparentize(55%),
    ),
    position: "background",
  ),
  cells: (body: [== Over the picture]),
)

// An omitted body gives a bare full-bleed slide.
#mosaic.slide(
  layout: mosaic.layouts.image(photo, position: "background"),
)

// `fit` overrides the per-position default. It rebuilds the picture, so it
// needs a path; ready-made content states its own fit and is rejected
// (tests/invalid/layouts-image-fit-content.typ).
#let dog = path("/docs-src/assets/images/dog.webp")
#mosaic.slide(
  layout: mosaic.layouts.image(dog, position: "left", fit: "contain"),
  cells: (header: [== Contained], body: [Uncropped picture.]),
)

// `fit:` is the shorthand for a bare path: `auto` takes the position's
// default, and an explicit value replaces it.
#import "../mosaic/src/layout/resolver.typ": resolve-layout
#import "../mosaic/src/settings.typ": make-settings
#import "support/grid.typ" as grid-test
#let picture-fit(layout) = {
  let resolved = resolve-layout(layout, make-settings())
  let picture = grid-test.info(resolved, "image").cell.content
  picture.fit
}
#assert(picture-fit(mosaic.layouts.image(dog, position: "left")) == "cover")
#assert(picture-fit(mosaic.layouts.image(dog, position: "left", fit: "contain")) == "contain")
#assert(picture-fit(mosaic.layouts.image(dog)) == "contain")
// Ready-made content with a scrim and a caption: the picture has no natural
// height to hug, so it takes the region above the caption.
#mosaic.slide(
  layout: mosaic.layouts.image(
    mosaic.components.image(dog, fit: "contain", scrim: black.transparentize(55%)),
    caption: [Scrimmed and captioned],
  ),
  cells: (header: [== Scrimmed figure]),
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
  position: "background",
  image: photo,
  cells: (body: [== Named selection, full bleed]),
)

// A scalar track sizes the picture and is side-independent: the same value
// mirrors cleanly across positions, with the companion region taking 1fr.
#for side in ("left", "right", "top", "bottom") {
  mosaic.slide(
    layout: "image",
    position: side,
    image: photo,
    tracks: 2fr,
    cells: (header: [== Scalar track #side], body: [Companion takes 1fr.]),
  )
}

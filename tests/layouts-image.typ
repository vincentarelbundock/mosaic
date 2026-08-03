#import "@local/mosaic:0.0.1" as mosaic

#show: mosaic.setup

#let photo = mosaic.components.image(path("/docs/assets/images/dog.webp"))

// The figure variant owns its picture and caption, so the slide supplies only
// the header cell.
#mosaic.slide(
  layout: mosaic.layouts.image(photo),
  content: (header: [== Figure, no caption]),
)

#mosaic.slide(
  layout: mosaic.layouts.image(photo, caption: [A captioned figure]),
  content: (header: [== Figure with caption]),
)

// Every directional variant pairs a full-bleed picture with header and body.
#for side in ("left", "right", "top", "bottom") {
  mosaic.slide(
    layout: mosaic.layouts.image(photo, variant: side),
    content: (header: [== Image #side], body: [Body beside the picture.]),
  )
}

// Directional tracks are two native sizes in visual order.
#mosaic.slide(
  layout: mosaic.layouts.image(photo, variant: "left", tracks: (2fr, 1fr)),
  content: (header: [== Weighted tracks], body: [Narrow text column.]),
)

// `full` composes into a single body cell with the picture behind it.
#mosaic.slide(
  layout: mosaic.layouts.image(
    (
      path: path("/docs/assets/images/dog.webp"),
      scrim: black.transparentize(55%),
    ),
    variant: "full",
  ),
  content: (body: [== Over the picture]),
)

// An empty body gives a bare full-bleed slide.
#mosaic.slide(
  layout: mosaic.layouts.image(photo, variant: "full"),
  content: (body: []),
)

// `fit` overrides the per-variant default.
#mosaic.slide(
  layout: mosaic.layouts.image(photo, variant: "left", fit: "contain"),
  content: (header: [== Contained], body: [Uncropped picture.]),
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
  content: (header: [== Named selection]),
)

#mosaic.slide(
  layout: "image",
  variant: "full",
  image: photo,
  content: (body: [== Named selection, full bleed]),
)

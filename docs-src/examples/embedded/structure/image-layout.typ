#import "@preview/mosaic:0.0.1" as m

#show: m.setup

// The default `figure` variant: a header above a contained picture, with an
// optional caption beneath. Charts and screenshots are never cropped.
#m.slide(
  layout: "image",
  image: path("/docs-src/assets/images/bonsai.webp"),
  caption: [Careful pruning, every year],
)[== The figure variant]

// A directional variant pairs a full-bleed picture with a header and body.
// `tracks` sizes the picture band; the first block is the header, the second
// is the body.
#m.slide(
  layout: "image",
  variant: "right",
  image: path("/docs-src/assets/images/dog.webp"),
  tracks: 45%,
)[== Picture beside text][
  - The picture covers the right band.
  - The text keeps the left.
]

// `bottom` stacks the text band above the picture. `fit: "contain"` keeps the
// whole picture visible instead of cropping it to fill the band.
#m.slide(
  layout: "image",
  variant: "bottom",
  image: path("/docs-src/assets/images/bonsai.webp"),
  fit: "contain",
)[== Picture below text][A single standing line above the picture.]

// `full` puts the picture behind one free-form body cell. The scrim quiets
// the photograph and the text fill supplies the contrast.
#m.slide(
  layout: "image",
  variant: "full",
  image: (
    path: path("/docs-src/assets/images/title-city.webp"),
    scrim: black.transparentize(45%),
  ),
)[
  #set text(fill: white)
  == Full-bleed photograph
]

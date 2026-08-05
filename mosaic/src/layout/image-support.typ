// Private image composition shared by title and section layouts.
#import "../shared.typ": fail
#import "../grid/constructors.typ": styled-cell, h, v
#import "../grid/model.typ": is-track-size
#import "support.typ": track-children, image-content


#let semantic-directional-variants = (
  "image-left",
  "image-right",
  "image-top",
  "image-bottom",
)
#let semantic-image-variants = semantic-directional-variants + ("image-background",)

#let semantic-image-position(variant) = if variant == "image-left" {
  "left"
} else if variant == "image-right" {
  "right"
} else if variant == "image-top" {
  "top"
} else {
  "bottom"
}

#let validate-semantic-image-use(fields, name) = {
  if fields.variant in semantic-image-variants and fields.image == none {
    fail(name + " variant " + repr(fields.variant) + " requires image")
  }
  if fields.variant not in semantic-image-variants and fields.image != none {
    fail(name + " variant " + repr(fields.variant) + " does not use image")
  }
  fields
}

// Two spellings, because authors ask two different questions. An array of 2 is
// visual order — "what occupies each side" — and must be mirrored by hand when
// the variant flips. A single track size answers "how much room does the
// picture get", which is side-independent: the companion region takes the
// remaining `1fr`, so `image-left` and `image-right` stay mirror images of each
// other without the caller reordering anything.
// A directional image layout is a two-region composition by definition: an
// image band and a text band, swapped by position. The pair is the API's shape,
// not a limit that a more general track list would lift, so the count is named
// rather than parameterized. A layout wanting more regions is a grid.
#let directional-cell-count = 2

#let validate-directional-tracks(tracks, name) = {
  if tracks != auto and not is-track-size(tracks) and (
    type(tracks) != array
      or tracks.len() != directional-cell-count
      or not tracks.all(is-track-size)
  ) {
    fail(
      name
        + " must be auto, one native Typst track size for the image, or an"
        + " array of 2 native Typst track sizes in visual order",
    )
  }
  tracks
}

// Resolves either spelling to the visual-order pair the grid expects.
#let directional-tracks(tracks, image-first) = if tracks == auto {
  auto
} else if type(tracks) == array {
  tracks
} else if image-first {
  (tracks, 1fr)
} else {
  (1fr, tracks)
}

#let fixed-image-content(value, name) = image-content(
  value,
  name,
  width: 100%,
  height: 100%,
  fit: "cover",
  allow-size: false,
)

#let optional-fixed-image(value, name) = if value == none {
  none
} else {
  fixed-image-content(value, name)
}

// Image cells are full-bleed: the photograph owns its region edge to edge and
// any framing is the image's own business.
#let image-cell(content) = styled-cell(
  content: content,
  id: "image",
  style: (
    content-sized: false,
    inset: 0pt,
  ),
)

#let directional-image-layout(
  variant,
  image,
  body,
  tracks: auto,
  gutter: 0pt,
) = {
  // `variant` is always the output of `semantic-image-position`, so it is one
  // of left/right/top/bottom by construction.
  _ = validate-directional-tracks(tracks, "directional image layout tracks")
  let image-first = variant in ("left", "top")
  let children = if image-first {
    (image, body)
  } else {
    (body, image)
  }
  let split = if variant in ("left", "right") { h } else { v }
  split(
    gutter: gutter,
    ..track-children(children, directional-tracks(tracks, image-first)),
  )
}

// Any tonal adjustment belongs to the picture itself (see the image dictionary's
// `scrim` key), so the background is the resolved image and nothing more.
#let image-background-cell(body, image) = body + (
  style: body.style + (background: image),
)

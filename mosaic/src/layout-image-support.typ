// Private image composition shared by title and section layouts.
#import "shared.typ": fail
#import "grid-model.typ": styled-cell, h, v, valid-track-size
#import "layout-support.typ": track-children, visual-content


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

#let validate-semantic-image-use(fields, subject) = {
  if fields.variant in semantic-image-variants and fields.image == none {
    fail(subject + " variant " + repr(fields.variant) + " requires image")
  }
  if fields.variant not in semantic-image-variants and fields.image != none {
    fail(subject + " variant " + repr(fields.variant) + " does not use image")
  }
}

#let validate-directional-tracks(tracks, subject) = {
  if tracks != auto and (
    type(tracks) != array
      or tracks.len() != 2
      or not tracks.all(valid-track-size)
  ) {
    fail(subject + " must be auto or an array of 2 native Typst track sizes")
  }
}

#let fixed-image-content(value, subject) = visual-content(
  value,
  subject: subject,
  width: 100%,
  height: 100%,
  fit: "cover",
  allow-size: false,
)

#let optional-fixed-image(value, subject) = if value == none {
  none
} else {
  fixed-image-content(value, subject)
}

// Image cells are full-bleed: the photograph owns its region edge to edge and
// any framing is the image's own business.
#let image-region(image-content, settings) = styled-cell(
  content: image-content,
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
  validate-directional-tracks(tracks, "directional image layout tracks")
  let children = if variant in ("left", "top") {
    (image, body)
  } else {
    (body, image)
  }
  let split = if variant in ("left", "right") { h } else { v }
  split(gutter: gutter, ..track-children(children, tracks))
}

#let image-background-cell(body, image, overlay: none) = {
  let background = if overlay == none {
    image
  } else {
    [
      #image
      #place(
        top + left,
        block(width: 100%, height: 100%, fill: overlay),
      )
    ]
  }
  body + (
    style: body.style + (background: background),
  )
}

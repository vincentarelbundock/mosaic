// Private image composition shared by title and section layouts.
#import "shared.typ": fail
#import "grid-model.typ": styled-cell, h, v, valid-track-size
#import "layout-support.typ": framed-surface, track-children, visual-content
#import "color-defaults.typ": default-canvas

#let directional-variants = ("left", "right", "top", "bottom")
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

#let image-region(image-content, settings, contained: false) = styled-cell(
  content: image-content,
  id: "image",
  style: if not contained {
    (
      content-sized: false,
      inset: 0pt,
    )
  } else {
    framed-surface(settings, fill: default-canvas, stroke: none) + (
      inset: settings.spacing.inset,
    )
  },
)

#let directional-image-layout(
  variant,
  image,
  body,
  tracks: auto,
  gutter: 0pt,
) = {
  if variant not in directional-variants {
    fail("directional image layout requires left, right, top, or bottom")
  }
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

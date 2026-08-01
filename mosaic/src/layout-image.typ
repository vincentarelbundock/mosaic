// Construction, validation, and resolution of the image layout.
#import "shared.typ": fail, valid-path
#import "grid-model.typ": styled-cell, h, v, valid-track-size
#import "layout-core.typ": make-grid
#import "layout-support.typ": (
  framed-surface,
  path-image,
  region-surface,
  track-children,
  visual-content,
)

#let variants = ("full", "figure", "left", "right", "top", "bottom")
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
  fields
}

#let validate-directional-tracks(tracks, subject) = {
  if tracks != auto and (
    type(tracks) != array
      or tracks.len() != 2
      or not tracks.all(valid-track-size)
  ) {
    fail(subject + " must be auto or an array of 2 native Typst track sizes")
  }
  tracks
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
      align: center + horizon,
      fill: none,
      radius: 0pt,
    )
  } else {
    framed-surface(settings, fill: settings.colors.canvas, stroke: none) + (
      inset: settings.spacing.inset,
      align: center + horizon,
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
  let _ = validate-directional-tracks(tracks, "directional image layout tracks")
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

#let validate-fields(fields) = {
  let variant = fields.variant
  if type(variant) != str or variant not in variants {
    fail(
      "layout \"image\" has unsupported variant " + repr(variant)
        + "; expected one of " + repr(variants),
    )
  }
  let tracks = fields.tracks
  if tracks != auto and (
    type(tracks) != array or tracks.len() == 0 or not tracks.all(valid-track-size)
  ) {
    fail(
      "layout \"image\" tracks must be auto "
        + "or an array of native Typst track sizes",
    )
  }
  if variant in directional-variants and tracks != auto and tracks.len() != 2 {
    fail("layout \"image\" split variants require exactly two tracks")
  }
  if variant not in directional-variants and tracks != auto {
    fail("layout \"image\" tracks apply only to split variants")
  }
  let path = fields.path
  let alt = fields.alt
  let fit = fields.fit
  if path != none and not valid-path(path) {
    fail("layout \"image\" path must be a non-empty string, native path, or none")
  }
  if alt != none and type(alt) != str {
    fail("layout \"image\" alt must be a string or none")
  }
  if type(fit) != str or fit not in ("cover", "contain", "stretch") {
    fail(
      "layout \"image\" fit must be \"cover\", \"contain\", or \"stretch\"",
    )
  }
  if path == none and (alt != none or fit != "cover") {
    fail("layout \"image\" alt and fit require path")
  }
  fields
}

/// Creates an image-first grid with no header or footer cells.
///
/// The `full` variant gives the image cell the complete body area without an
/// inset. The `figure` variant presents one contained image with the standard
/// slide inset. The `left`, `right`, `top`, and `bottom` variants pair a
/// full-bleed image cell with a body cell.
///
/// Native Typst tracks are controlled by `tracks`. `auto` gives directional
/// variants two equal columns or rows.
///
/// For `left` and `top`, body order is `image`, then `body`; for `right` and
/// `bottom`, it is `body`, then `image`. When `path` is provided, the image is
/// fixed in its cell and the slide supplies only the remaining body, if any.
/// Mosaic sets the image width and height to `100%` and uses `fit: "cover"` by
/// default. Without `path`, supply native image content as a slide body.
///
/// - variant (str): `full`, `figure`, `left`, `right`, `top`, or `bottom`.
/// - path (none | str | path): Optional image path. Use a native `path` for
///   project assets when Mosaic is imported as a package.
/// - alt (none | str): Alternative text used with `path`.
/// - fit (str): `cover`, `contain`, or `stretch`.
/// - tracks (auto | array): Native Typst tracks in visual order for split layouts.
///
/// -> dictionary
#let image(
  variant: "full",
  path: none,
  alt: none,
  fit: "cover",
  tracks: auto,
) = {
  let fields = validate-fields((
    variant: variant,
    path: path,
    alt: alt,
    fit: fit,
    tracks: tracks,
  ))
  make-grid("image", fields)
}

#let body-cell(settings) = styled-cell(
  id: "body",
  // No text delta: the body inherits ambient `set text` so themes and native
  // overrides compose. Surface colors remain explicit.
  style: (
    content-sized: false,
    inset: settings.spacing.inset,
    align: left + top,
  ) + region-surface(auto, none, settings),
)

#let resolve-image(command, settings) = {
  let fields = validate-fields(command.fields)
  let image-content = if fields.path == none {
    none
  } else {
    path-image(
      (
        path: fields.path,
        alt: fields.alt,
        fit: fields.fit,
      ),
      "layout \"image\" path",
      width: 100%,
      height: 100%,
      allow-size: false,
    )
  }
  if fields.variant in directional-variants {
    directional-image-layout(
      fields.variant,
      image-region(image-content, settings),
      body-cell(settings),
      tracks: fields.tracks,
      gutter: settings.spacing.gap,
    )
  } else {
    image-region(image-content, settings, contained: fields.variant == "figure")
  }
}

// Construction, validation, and resolution of the image layout.
//
// This is the image-first counterpart to the content layout: the picture is the
// argument, and the text regions arrange around it. Content slides stay free of
// image plumbing, and the directional geometry is the same private machinery
// title and section layouts already use.
#import "../shared.typ": fail
#import "../grid/constructors.typ": styled-cell, v, t
#import "core.typ": make-layout, validate-visual-spec
#import "support.typ": (
  affix,
  compact-region-insets,
  subordinate-block,
  visual-content,
)
#import "image-support.typ": (
  directional-image-layout,
  image-background-cell,
  image-region,
  validate-directional-tracks,
)

#let directional-variants = ("left", "right", "top", "bottom")
#let variants = ("figure", "full") + directional-variants

#let fit-modes = ("cover", "contain", "stretch")

#let validate-fields(fields) = {
  let variant = fields.variant
  if type(variant) != str or variant not in variants {
    fail(
      "layout \"image\" has unsupported variant " + repr(variant)
        + "; expected one of " + repr(variants),
    )
  }
  if fields.image == none {
    fail("layout \"image\" requires an image")
  }
  let _ = validate-visual-spec(
    fields.image,
    "layout \"image\" image",
    allow-size: false,
  )
  if fields.fit != auto and (
    type(fields.fit) != str or fields.fit not in fit-modes
  ) {
    fail("layout \"image\" fit must be auto, " + repr(fit-modes).slice(1))
  }
  if fields.caption != none and variant != "figure" {
    fail("layout \"image\" caption applies only to the \"figure\" variant")
  }
  if variant in directional-variants {
    validate-directional-tracks(fields.tracks, "layout \"image\" tracks")
  } else if fields.tracks != auto {
    fail("layout \"image\" tracks apply only to directional variants")
  }
  fields
}

/// Creates an image-first grid recipe.
///
/// The image is the layout's subject and is supplied here rather than as slide
/// content; the surrounding `mosaic.slide` fills only the text cells.
///
/// `figure` centers a contained image under a `header` cell, with an optional
/// `caption` below it — the conventional academic figure slide. `left`,
/// `right`, `top`, and `bottom` pair a full-bleed image with a text region of
/// `header` and `body` cells, using the same private directional machinery as
/// image-bearing title and section layouts. `full` places the image behind a
/// single `body` cell, so text reads over the photograph; a background is a
/// cell style rather than a split style, so this variant composes into one cell
/// as image-background title and section layouts do. Put a heading inside the
/// body to title it, or pass an empty block for a bare full-bleed slide.
///
/// `fit` defaults to `"contain"` for `figure`, which must never crop a chart,
/// and to `"cover"` for every other variant, where the picture fills its
/// region. Pass `"cover"`, `"contain"`, or `"stretch"` to override.
///
/// The layout is purely structural. Resolved cells are labeled
/// `<mosaic-cell-header>`, `<mosaic-cell-body>`, `<mosaic-cell-image>`, and
/// `<mosaic-cell-caption>`, so appearance is supplied with native Typst rules.
/// `full` inherits the surrounding native text color, so quiet the photograph
/// with the image spec's `scrim` key, as in
/// `(path: "photo.webp", scrim: black.transparentize(55%))`, and override the
/// cell's text fill for light-on-dark compositions.
///
/// - image (content | str | path | dictionary): The picture, as the sole positional argument.
/// - variant (str): `figure`, `full`, `left`, `right`, `top`, or `bottom`.
/// - caption (content | none): Caption below a `figure`; rejected by other variants.
/// - fit (auto | str): Native fitting mode, or `auto` for the per-variant default.
/// - tracks (auto | array): Two native Typst tracks, in visual order, for directional variants.
///
/// -> dictionary
#let image(
  /// The picture the slide is built around.
  /// -> content | str | path | dictionary
  image,
  /// Structural arrangement of picture and text.
  /// -> str
  variant: "figure",
  /// Optional caption rendered below a `figure` image.
  /// -> content | none
  caption: none,
  /// Native Typst fitting mode, or `auto` for the variant default.
  /// -> auto | str
  fit: auto,
  /// Native Typst tracks for directional variants, in visual order.
  /// -> auto | array
  tracks: auto,
) = {
  let fields = validate-fields((
    caption: caption,
    fit: fit,
    image: image,
    tracks: tracks,
    variant: variant,
  ))
  make-layout("image", fields)
}

#let text-cell(id, settings, content-sized: false, edge: false) = styled-cell(
  id: id,
  style: (
    content-sized: content-sized,
    inset: if edge {
      compact-region-insets(settings)
    } else {
      settings.spacing.inset
    },
  ),
)

// Header above, body filling the rest: the arrangement that sits beside a
// directional image and over a full-bleed one.
#let text-region(settings) = v(
  t(auto, text-cell("header", settings, content-sized: true, edge: true)),
  t(1fr, text-cell("body", settings)),
)

#let resolve-image-layout(command, settings) = {
  let fields = validate-fields(command.fields)
  let default-fit = if fields.variant == "figure" { "contain" } else { "cover" }
  let picture = visual-content(
    fields.image,
    subject: "layout \"image\" image",
    width: 100%,
    height: 100%,
    fit: if fields.fit == auto { default-fit } else { fields.fit },
    allow-size: false,
  )

  if fields.variant == "figure" {
    let children = (
      t(auto, text-cell("header", settings, content-sized: true, edge: true)),
      // The picture owns a fixed cell, so the slide supplies no block for it.
      t(1fr, styled-cell(
        id: "image",
        content: picture,
        style: (content-sized: false, inset: settings.spacing.inset),
      )),
    )
    if fields.caption != none {
      children.push(t(auto, styled-cell(
        id: "caption",
        content: subordinate-block(
          affix(fields.caption),
          settings.type.caption,
          settings,
        ),
        style: (content-sized: true, inset: compact-region-insets(settings)),
      )))
    }
    v(..children)
  } else if fields.variant == "full" {
    // A background is a cell style, not a split style, so the full-bleed
    // variant composes into a single cell exactly as image-background title
    // and section layouts do. Put a heading inside the body to title it.
    image-background-cell(
      text-cell("body", settings, content-sized: false),
      picture,
    )
  } else {
    directional-image-layout(
      fields.variant,
      image-region(picture, settings),
      text-region(settings),
      tracks: fields.tracks,
      gutter: settings.spacing.gap,
    )
  }
}

// Construction, validation, and resolution of the image layout.
//
// This is the image-first counterpart to the content layout: the picture is the
// argument, and the text regions arrange around it. Content slides stay free of
// image plumbing, and the directional geometry is the same private machinery
// title and section layouts already use.
#import "../shared.typ": fail
#import "../caption-fit.typ": captioned-picture
#import "../grid/constructors.typ": styled-cell, v, t
#import "core.typ": image-fit-modes, make-layout, validate-visual-spec
#import "support.typ": visual-content, header-inset
#import "image-support.typ": (
  directional-image-layout,
  image-background-cell,
  image-region,
  validate-directional-tracks,
)

#let directional-variants = ("left", "right", "top", "bottom")
#let variants = ("figure", "full") + directional-variants

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
    type(fields.fit) != str or fields.fit not in image-fit-modes
  ) {
    fail("layout \"image\" fit must be auto, \"cover\", or \"contain\"")
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
/// This is the image-first counterpart to `layouts.content`: the picture is the
/// argument rather than slide content, and the text regions arrange around it.
/// The surrounding `mosaic.slide` fills only the text cells.
///
/// ```typ
/// #mosaic.slide(
///   layout: mosaic.layouts.image(
///     path("chart.webp"),
///     caption: [Revenue by quarter],
///   ),
///   [== Results],
/// )
/// ```
///
/// *Variants*
///
/// - `figure`: a contained picture centered under a `header` cell, with an
///   optional `caption` below it. The conventional academic figure slide, and
///   the default.
/// - `left`, `right`, `top`, `bottom`: a full-bleed picture paired with a text
///   region of `header` and `body` cells, sized by `tracks`.
/// - `full`: the picture behind a single `body` cell, so text reads over the
///   photograph. Put a heading inside the body to title it, or pass an empty
///   block for a bare full-bleed slide.
///
/// *Captions*
///
/// A `caption` composes a native Typst `figure` around the picture, so it takes
/// the deck's own `show figure.caption` styling and figure numbering. Switch the
/// numbering off with an ordinary `set figure(numbering: none)`. Captions are
/// accepted by the `figure` variant only.
///
/// *Styling*
///
/// The layout is purely structural. Resolved cells are labeled
/// `<mosaic-cell-header>`, `<mosaic-cell-body>`, and `<mosaic-cell-image>`, so
/// appearance comes from native Typst rules. The `full` variant inherits the
/// surrounding native text color, so quiet the photograph with the image spec's
/// `scrim` key and override the cell's text fill.
///
/// ```typ
/// #show label("mosaic-cell-body"): set text(fill: white)
/// #mosaic.slide(
///   layout: mosaic.layouts.image(
///     (path: "photo.webp", scrim: black.transparentize(55%)),
///     variant: "full",
///   ),
///   [== Full bleed],
/// )
/// ```
///
/// -> dictionary
#let image(
  /// The picture the slide is built around, as the sole positional argument.
  /// Give a path, ready-made content, or a dictionary spec whose `scrim` key
  /// paints a layer over the picture and under any text composed on top of it.
  /// -> content | str | path | dictionary
  image,
  /// Structural arrangement of picture and text: `figure`, `full`, `left`,
  /// `right`, `top`, or `bottom`.
  /// -> str
  variant: "figure",
  /// Caption composed below a `figure` picture. Rejected by the other variants.
  /// -> content | none
  caption: none,
  /// How the picture fills its region.
  ///
  /// - `"contain"`: fit the whole picture inside the region. The `figure`
  ///   default, since a chart must never be cropped.
  /// - `"cover"`: fill the region, cropping the overhang. The default for every
  ///   other variant.
  ///
  /// `auto` picks the per-variant default above.
  /// -> auto | str
  fit: auto,
  /// Sizes the split of a directional variant, and is rejected by `figure` and
  /// `full`. One native Typst track size answers "how much room does the picture
  /// get" and is side-independent, so `left` and `right` stay mirror images
  /// without reordering anything; the text region takes the remaining `1fr`. An
  /// array of two is in visual order instead, and must be mirrored by hand when
  /// the variant flips.
  /// -> auto | length | ratio | relative | fraction | array
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

#let text-cell(id, settings, content-sized: false) = styled-cell(
  id: id,
  style: (
    content-sized: content-sized,
    // A header is one line tall, so it takes the shallower edge padding; the
    // body keeps the deck inset on all four sides.
    inset: if id == "header" {
      header-inset(settings)
    } else {
      settings.spacing.inset
    },
  ),
)

// Header above, body filling the rest: the arrangement that sits beside a
// directional image and over a full-bleed one.
#let text-region(settings) = v(
  t(auto, text-cell("header", settings, content-sized: true)),
  t(1fr, text-cell("body", settings)),
)

#let resolve-image-layout(command, settings) = {
  let fields = validate-fields(command.fields)
  let default-fit = if fields.variant == "figure" { "contain" } else { "cover" }
  let fitting = if fields.fit == auto { default-fit } else { fields.fit }
  // Rebuilds the picture at a given size. A picture supplied as ready-made
  // content cannot be rebuilt, so it is boxed at that size instead.
  let resize(height, width) = if type(fields.image) == content {
    block(width: width, height: height, fields.image)
  } else {
    visual-content(
      fields.image,
      subject: "layout \"image\" image",
      width: width,
      height: height,
      fit: fitting,
      allow-size: false,
    )
  }
  let picture = resize(100%, 100%)

  if fields.variant == "figure" {
    // Picture and caption are one figure, not two stacked regions: the caption
    // is measured, the picture takes what is left, and the picture's box hugs
    // its natural height so the caption sits directly beneath the image rather
    // than being pinned to the bottom edge of the slide.
    let content = if fields.caption == none {
      picture
    } else {
      captioned-picture(resize, fields.caption)
    }
    let children = (
      t(auto, text-cell("header", settings, content-sized: true)),
      // The picture owns a fixed cell, so the slide supplies no block for it.
      t(1fr, styled-cell(
        id: "image",
        content: content,
        style: (content-sized: false, inset: settings.spacing.inset),
      )),
    )
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
      image-region(picture),
      text-region(settings),
      tracks: fields.tracks,
      gutter: settings.spacing.gap,
    )
  }
}

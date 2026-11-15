// Construction, validation, and resolution of the image layout.
//
// This is the image-first counterpart to the content layout: the picture is the
// argument, and the text regions arrange around it. Content slides stay free of
// image plumbing, and the directional geometry is the same private machinery
// title and section layouts already use.
#import "../shared.typ": fail
#import "../caption-fit.typ": captioned-image
#import "../grid/constructors.typ": make-cell, rows, track
#import "core.typ": image-fit-modes, make-layout, validate-image
#import "support.typ": as-content, image-content, inset-cell
#import "image-support.typ": (
  directional-image-layout,
  directional-positions,
  image-positions,
  image-background-cell,
  image-cell,
  validate-directional-tracks,
)

// Where the picture sits. The image layout shares the position vocabulary of
// the title and section layouts and adds one place of its own: `body`, the
// picture as a figure in the body region under the header.
#let positions = ("body",) + image-positions

// The `variant` argument this layout had before `position` named the
// picture's place. It had no text design to select, so nothing replaces it.
#let removed-variants = (
  figure: "body",
  full: "background",
  left: "left",
  right: "right",
  top: "top",
  bottom: "bottom",
)

#let validate-fields(fields) = {
  let position = fields.position
  if type(position) != str or position not in positions {
    fail("layout \"image\" position must be one of " + repr(positions))
  }
  if fields.image == none {
    fail("layout \"image\" requires an image")
  }
  _ = validate-image(fields.image, "layout \"image\" image")
  if fields.fit != auto and (
    type(fields.fit) != str or fields.fit not in image-fit-modes
  ) {
    fail("layout \"image\" fit must be auto, \"cover\", or \"contain\"")
  }
  // Ready-made content is already an image element with a fit of its own, and
  // nothing here can rebuild it, so a `fit:` beside it would be dropped.
  if fields.fit != auto and type(fields.image) == content {
    fail(
      "layout \"image\" fit applies only to a path image; ready-made content "
        + "states its own fit",
    )
  }
  if fields.caption != none and type(fields.caption) not in (content, str) {
    fail("layout \"image\" caption must be content, a string, or none")
  }
  if fields.caption != none and position != "body" {
    fail("layout \"image\" caption applies only to position \"body\"")
  }
  if position in directional-positions {
    _ = validate-directional-tracks(fields.tracks, "layout \"image\" tracks")
  } else if fields.tracks != auto {
    fail(
      "layout \"image\" tracks size a split, so they apply only to positions "
        + repr(directional-positions),
    )
  }
  fields
}

/// Creates an image-first grid recipe.
///
/// This is the image-first counterpart to `layouts.content`: the picture is the
/// argument rather than slide content, and the text regions arrange around it.
/// The surrounding `mosaic.slide` fills only the text cells, by its one rule:
/// the slide's opening heading is its header, and everything else fills the
/// cells. At `"body"` the slide therefore needs nothing but that heading; at a
/// directional position it takes the heading and one body; at `"background"`
/// there is no `header` cell, so a heading stays in the one body.
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
/// *Positions*
///
/// `position` names the picture's place, in the vocabulary every layout with
/// a picture shares, plus `"body"`:
///
/// - `"body"`: the picture in the body region under a `header` cell, with an
///   optional `caption` below it. A picture given as a path is contained, so
///   it is never cropped, and sits centered in the region. The conventional
///   academic figure slide, and the default.
/// - `"left"`, `"right"`, `"top"`, `"bottom"`: a full-bleed picture paired
///   with a text region of `header` and `body` cells, sized by `tracks`.
/// - `"background"`: the picture behind a single `body` cell, so text reads
///   over the photograph. Open the body with a heading to title it, or give
///   no body at all for a bare full-bleed slide.
///
/// The layout has no `variant`: it carries no text design of its own.
///
/// *Captions*
///
/// A `caption` composes a native Typst `figure` around the picture, so it takes
/// the deck's own `show figure.caption` styling and figure numbering. Switch the
/// numbering off with an ordinary `set figure(numbering: none)`. Captions are
/// accepted at position `"body"` only.
///
/// *Labels*
///
/// Every resolved cell carries a label, so appearance comes from native Typst
/// rules:
///
/// - `mosaic-cell-header`: the header, at `"body"` and the directional
///   positions.
/// - `mosaic-cell-body`: the text region, at the directional positions and
///   `"background"`.
/// - `mosaic-cell-image`: the picture, at `"body"` and the directional
///   positions. At `"background"` the picture is the body cell's background
///   instead, so it has no image cell of its own.
///
/// *Styling*
///
/// The layout is purely structural, so its looks come from rules on those
/// labels. At `"background"` the text inherits the surrounding native text
/// color, so quiet the photograph with the `scrim` argument of
/// `components.image` and override the cell's text fill.
///
/// ```typ
/// #show label("mosaic-cell-body"): set text(fill: white)
/// #mosaic.slide(
///   layout: mosaic.layouts.image(
///     mosaic.components.image(
///       path("photo.webp"),
///       scrim: black.transparentize(55%),
///     ),
///     position: "background",
///   ),
///   [== Full bleed],
/// )
/// ```
///
/// -> dictionary
#let image(
  /// The picture the slide is built around, as the sole positional argument.
  /// Give a native `path(..)` value, which is sized and fitted to its region,
  /// or ready-made content such as `components.image(path(..), scrim: ..)`,
  /// which states its own fit and scrim. A bare string is rejected: it would
  /// resolve inside the package rather than in the deck's project.
  /// -> content | path
  image,
  /// Where the picture sits: `"body"`, `"left"`, `"right"`, `"top"`,
  /// `"bottom"`, or `"background"`.
  /// -> str
  position: "body",
  /// Caption composed below a picture at position `"body"`. Rejected at the
  /// other positions.
  /// -> content | str | none
  caption: none,
  /// How a picture given as a bare path fills its region.
  ///
  /// - `"contain"`: fit the whole picture inside the region. The default at
  ///   `"body"`, since a chart must never be cropped.
  /// - `"cover"`: fill the region, cropping the overhang. The default at every
  ///   other position.
  ///
  /// `auto` picks the per-position default above. Rejected beside ready-made
  /// content, which states its own fit and cannot be rebuilt: pass
  /// `components.image(path(..), fit: ..)` there instead.
  /// -> auto | str
  fit: auto,
  /// Sizes the split of a directional position, and is rejected at `"body"`
  /// and `"background"`. One native Typst track size answers "how much room
  /// does the picture get" and is side-independent, so `left` and `right`
  /// stay mirror images without reordering anything; the text region takes
  /// the remaining `1fr`. An array of two is in visual order instead, and
  /// must be mirrored by hand when the position flips.
  /// -> auto | length | ratio | relative | fraction | array
  tracks: auto,
  /// Catches removed arguments so they fail with the spelling that replaced
  /// them. Accepts nothing.
  /// -> arguments
  ..removed,
) = {
  if removed.pos().len() > 0 {
    fail("layout \"image\" takes one picture as its sole positional argument")
  }
  for (name, value) in removed.named() {
    if name == "variant" {
      fail(
        "layout \"image\" variant was removed; write position: "
          + repr(removed-variants.at(
            if type(value) == str { value } else { "" },
            default: "body",
          )),
      )
    }
    fail("layout \"image\" has no argument " + repr(name))
  }
  let fields = validate-fields((
    caption: caption,
    fit: fit,
    image: image,
    position: position,
    tracks: tracks,
  ))
  make-layout("image", fields)
}

// Header above, body filling the rest: the arrangement that sits beside a
// directional image and over a full-bleed one. The header is one line tall,
// so it takes the compact inset; the body keeps the deck inset on
// all four sides.
#let text-column(settings) = rows(
  track(auto, inset-cell(
    "header",
    settings,
    content-sized: true,
  )),
  track(1fr, inset-cell("body", settings)),
)

#let resolve-image-layout(command, settings) = {
  let fields = validate-fields(command.fields)
  let default-fit = if fields.position == "body" { "contain" } else { "cover" }
  let fitting = if fields.fit == auto { default-fit } else { fields.fit }
  // Rebuilds the picture at a given size. A picture supplied as ready-made
  // content cannot be rebuilt, so it is boxed at that size instead.
  let resize(height, width) = if type(fields.image) == content {
    block(width: width, height: height, fields.image)
  } else {
    image-content(
      fields.image,
      "layout \"image\" image",
      width: width,
      height: height,
      fit: fitting,
    )
  }
  let picture = resize(100%, 100%)

  if fields.position == "body" {
    // Picture and caption are one figure, not two stacked regions: the caption
    // is measured, the picture takes what is left, and the picture's box hugs
    // its natural height so the caption sits directly beneath the image rather
    // than being pinned to the bottom edge of the slide.
    let content = if fields.caption == none {
      picture
    } else {
      // A path picture is rebuilt at its natural height, so the caption hugs
      // it. Ready-made content has no natural height to ask for (a scrimmed
      // picture is a block that fills whatever it is given), so it takes the
      // whole region above the caption instead.
      captioned-image(
        resize,
        as-content(fields.caption),
        pin: type(fields.image) == content,
      )
    }
    rows(
      track(auto, inset-cell(
        "header",
        settings,
        content-sized: true,
      )),
      // The picture owns a fixed cell, so the slide supplies no block for it.
      track(1fr, make-cell(
        id: "image",
        content: content,
        style: (content-sized: false, inset: settings.spacing.inset),
      )),
    )
  } else if fields.position == "background" {
    // A background is a cell style, not a split style, so the full-bleed
    // position composes into a single cell exactly as it does in the title
    // and section layouts. Put a heading inside the body to title it.
    image-background-cell(
      inset-cell("body", settings),
      picture,
    )
  } else {
    // No gutter: a full-bleed picture is its own edge, and the text region
    // already keeps the deck inset on all four sides, so a gap here would be
    // padding on top of padding. It also lets a recolored header band reach
    // the picture instead of stopping short of it across a stripe of canvas.
    directional-image-layout(
      fields.position,
      image-cell(picture),
      text-column(settings),
      tracks: fields.tracks,
    )
  }
}

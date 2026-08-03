// Construction, validation, and resolution of the section layout.
#import "../shared.typ": fail
#import "../grid/constructors.typ": styled-cell
#import "core.typ": (
  make-layout,
  validate-accent,
  validate-visual-spec,
)

#import "support.typ": subordinate-block, affix
#import "image-support.typ": (
  directional-image-layout,
  image-background-cell,
  image-region,
  optional-fixed-image,
  semantic-directional-variants,
  semantic-image-position,
  semantic-image-variants,
  validate-directional-tracks,
  validate-semantic-image-use,
)

#let variants = ("plain",) + semantic-image-variants

#let validate-fields(fields, allow-auto: false) = {
  validate-accent(fields, "section", allow-auto: allow-auto)
  let variant = fields.variant
  if type(variant) != str or variant not in variants {
    fail(
      "layout \"section\" has unsupported variant " + repr(variant)
        + "; expected one of " + repr(variants),
    )
  }
  validate-semantic-image-use(fields, "layout \"section\"")
  if fields.image != none {
    let _ = validate-visual-spec(
      fields.image,
      "layout \"section\" image",
    )
  }
  if variant in semantic-directional-variants {
    validate-directional-tracks(fields.tracks, "layout \"section\" tracks")
  } else if fields.tracks != auto {
    fail("layout \"section\" tracks apply only to directional image variants")
  }
  fields
}

/// Creates a section divider grid.
///
/// `plain` provides one centered `section` cell. `image-left`, `image-right`,
/// `image-top`, and `image-bottom` pair that cell with a full-bleed `image`
/// cell using the same private directional machinery as image-bearing title
/// layouts.
/// `image-background` places the image behind the section cell; the text
/// inherits the surrounding native text color, so quiet the photograph with
/// the image spec's `scrim` key, as in
/// `image: (path: "cover.webp", scrim: black.transparentize(55%))`, and
/// override the `section` cell's text fill for light-on-dark compositions.
/// Image variants require `image`.
/// Directional `tracks` are one native Typst track size for the image, or two
/// in visual order.
#let section(
  subtitle: none,
  number: none,
  image: none,
  variant: "plain",
  /// Color used by the optional section number. `auto` inherits the semantic
  /// accent resolved by `setup`.
  /// -> color | auto
  accent: auto,
  tracks: auto,
) = {
  let fields = validate-fields((
    subtitle: subtitle,
    number: number,
    image: image,
    variant: variant,
    accent: accent,
    tracks: tracks,
  ), allow-auto: true)
  make-layout("section", fields)
}

#let resolve-section(command, settings) = {
  let fields = validate-fields(command.fields + (
    accent: if command.fields.accent == auto { settings.colors.accent } else { command.fields.accent },
  ))
  let image = optional-fixed-image(fields.image, "layout \"section\" image")
  let before = if fields.number != none {
    text(..settings.type.small, fill: fields.accent, fields.number)
    parbreak()
  } else {
    []
  }
  let after = subordinate-block(
    fields.subtitle,
    settings.type.subtitle,
    settings,
    above: settings.spacing.compact-gap,
  )
  // Structural only: the section cell's centered arrangement and title
  // typography come from the <mosaic-cell-section> label rules in `setup`.
  let section-cell = styled-cell(
    id: "section",
    style: (
      before: affix(before),
      after: affix(after),
      content-sized: fields.variant in semantic-directional-variants,
      fit: "width",
      inset: settings.spacing.inset,
    ),
  )
  if fields.variant in semantic-directional-variants {
    let position = semantic-image-position(fields.variant)
    directional-image-layout(
      position,
      image-region(image, settings),
      section-cell,
      tracks: fields.tracks,
      gutter: settings.spacing.gap,
    )
  } else if fields.variant == "image-background" {
    image-background-cell(section-cell, image)
  } else {
    section-cell
  }
}

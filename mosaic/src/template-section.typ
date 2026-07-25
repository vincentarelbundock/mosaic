// Construction, validation, and resolution of the section template.
#import "shared.typ": fail
#import "grid-model.typ": styled-cell
#import "template-core.typ": (
  make-grid,
  validate-role,
  validate-visual-spec,
)
#import "template-support.typ": optional, affix
#import "template-image.typ": (
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

#let validate-fields(fields) = {
  let _ = validate-role(fields)
  let variant = fields.variant
  if type(variant) != str or variant not in variants {
    fail(
      "template \"section\" has unsupported variant " + repr(variant)
        + "; expected one of " + repr(variants),
    )
  }
  let _ = validate-semantic-image-use(fields, "template \"section\"")
  if fields.image != none {
    let _ = validate-visual-spec(
      fields.image,
      "template \"section\" image",
    )
  }
  if variant in semantic-directional-variants {
    let _ = validate-directional-tracks(fields.tracks, "template \"section\" tracks")
  } else if fields.tracks != auto {
    fail("template \"section\" tracks apply only to directional image variants")
  }
  fields
}

/// Creates a section divider grid.
///
/// `plain` provides one centered `section` cell. `image-left`, `image-right`,
/// `image-top`, and `image-bottom` pair that cell with a full-bleed `image`
/// cell using the same directional layout machinery as `templates.image`.
/// `image-background` places the image behind the section cell with a black
/// readability scrim and white text. Image variants require `image`.
/// Directional `tracks` are two native Typst track sizes in visual order.
#let section(
  subtitle: none,
  number: none,
  image: none,
  variant: "plain",
  role: "accent",
  tracks: auto,
) = {
  let fields = validate-fields((
    subtitle: subtitle,
    number: number,
    image: image,
    variant: variant,
    role: role,
    tracks: tracks,
  ))
  make-grid("section", fields)
}

#let resolve-section(command, settings) = {
  let fields = validate-fields(command.fields)
  let image = optional-fixed-image(fields.image, "template \"section\" image")
  let before = if fields.number != none {
    text(..settings.type.small, fill: settings.colors.accent, fields.number)
    parbreak()
  } else {
    []
  }
  let after = optional(
    fields.subtitle,
    settings.type.subtitle,
    above: settings.spacing.compact-gap,
  )
  let section-cell = styled-cell(
    id: "section",
    style: (
      before: affix(before),
      after: affix(after),
      content-sized: fields.variant in semantic-directional-variants,
      inset: settings.spacing.inset,
      align: center + horizon,
      fill: if fields.variant == "image-background" {
        black.transparentize(35%)
      } else {
        settings.colors.canvas
      },
      text: settings.type.title + (
        fill: if fields.variant == "image-background" {
          white
        } else {
          settings.colors.text
        },
      ),
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

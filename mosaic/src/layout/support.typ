// Shared content and surface primitives for layout resolvers.
#import "../grid/constructors.typ": styled-cell, t
#import "../component/image.typ": image as mosaic-image
#import "core.typ": validate-visual-spec

// Subordinate tiers composed inside a single cell (title subtitle, title
// metadata, section subtitle) pin a muted `fill` so they read as secondary on
// the default surface. That fill must not survive a recolored cell: a
// light-on-dark composition sets one rule on <mosaic-cell-title> and expects
// the whole stack to follow.
#let inherit-fill(styles) = if "fill" in styles {
  let styles = styles
  let _ = styles.remove("fill")
  styles
} else {
  styles
}

// Keeps the muted tier muted while the cell still carries the deck's ordinary
// text color, and hands the tier over to the inherited fill as soon as
// anything overrides it. Call inside a `context` block: it reads `text.fill`.
#let adapt-fill(styles, settings) = if text.fill == settings.colors.text {
  styles
} else {
  inherit-fill(styles)
}

// Places one such tier below the cell's primary content, or nothing when the
// field is absent.
#let subordinate-block(body, styles, settings, above: 0pt) = if body == none {
  []
} else {
  block(above: above, context text(..adapt-fill(styles, settings), body))
}

#let as-content(value) = if value == none {
  none
} else if type(value) == content {
  value
} else {
  [#value]
}

#let affix(value) = if value == none { [] } else { as-content(value) }

// Edge regions (headers, footers, captions) hug their own content vertically
// while keeping the deck's horizontal inset, so they align with body text.
// Shared by the content and image layouts.
#let compact-region-insets(settings) = (
  top: settings.spacing.compact-gap,
  right: settings.spacing.inset,
  bottom: settings.spacing.compact-gap,
  left: settings.spacing.inset,
)

#let track-children(nodes, tracks) = if tracks == auto {
  nodes
} else {
  nodes.zip(tracks).map(((node, size)) => t(size, node))
}

#let visual-path(value) = if type(value) != str {
  value
} else if value.starts-with("/") {
  value
} else {
  "/" + value
}

#let path-image(
  value,
  subject,
  width: auto,
  height: auto,
  fit: "cover",
  allow-size: true,
) = {
  let spec = validate-visual-spec(value, subject, allow-size: allow-size)
  let alt = spec.at("alt", default: none)
  let image-fit = spec.at("fit", default: fit)
  // The scrim rides the picture rather than the cell, so it hugs an inset
  // figure exactly as it covers a full-bleed background.
  mosaic-image(
    visual-path(spec.path),
    alt: alt,
    width: if allow-size { spec.at("width", default: width) } else { width },
    height: if allow-size { spec.at("height", default: height) } else { height },
    fit: image-fit,
    scrim: spec.at("scrim", default: none),
  )
}

#let visual-content(
  value,
  subject: "image specification",
  width: auto,
  height: auto,
  fit: "cover",
  allow-size: true,
) = {
  if type(value) == content {
    value
  } else {
    path-image(
      value,
      subject,
      width: width,
      height: height,
      fit: fit,
      allow-size: allow-size,
    )
  }
}

// Structural fixed-content cell. Typography is not threaded here: the cell's
// <mosaic-cell-ID> label carries it through native show rules.
#let fixed-cell(
  body,
  id,
  settings,
  inset: none,
  content-sized: true,
  surface: (:),
) = styled-cell(
  content: as-content(body),
  id: id,
  style: (
    content-sized: content-sized,
    inset: if inset == none { settings.spacing.compact-gap } else { inset },
  ) + surface,
)

// Shared content and surface primitives for layout resolvers.
#import "grid-model.typ": styled-cell, t
#import "image.typ": image as mosaic-image
#import "layout-core.typ": validate-visual-spec

#let optional(body, styles, above: 0pt) = if body == none {
  []
} else {
  block(above: above, text(..styles, body))
}

#let as-content(value) = if value == none {
  none
} else if type(value) == content {
  value
} else {
  [#value]
}

#let affix(value) = if value == none { [] } else { as-content(value) }

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
  mosaic-image(
    visual-path(spec.path),
    alt: alt,
    width: if allow-size { spec.at("width", default: width) } else { width },
    height: if allow-size { spec.at("height", default: height) } else { height },
    fit: image-fit,
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

#let framed-surface(settings, fill: auto, stroke: auto) = (
  radius: if settings.features.rounded { settings.shape.radius } else { 0pt },
  fill: if fill == auto { settings.colors.surface } else { fill },
  stroke: if stroke == auto {
    settings.shape.stroke + settings.colors.line
  } else {
    stroke
  },
)

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

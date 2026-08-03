// Clipped, semantically styled block used as the base of other components.
#import "style.typ": normalize-style, styled-body

/// Wraps content in a clipped, semantically styled block.
///
/// -> content
#let frame(
  /// Content inside the frame.
  /// -> content
  body,
  /// Semantic role name.
  /// -> str
  role: "neutral",
  /// Component-style overrides.
  /// -> dictionary
  style: (:),
  /// Native block width.
  /// -> auto | length | relative | fraction
  width: auto,
  /// Native block height.
  /// -> auto | length | relative | fraction
  height: auto,
) = context {
  let it = normalize-style(style: style, role-name: role, contextual: true)
  block(
    width: width,
    height: height,
    fill: it.fill,
    stroke: it.stroke,
    radius: it.radius,
    inset: it.inset,
    clip: true,
    styled-body(it, body),
  )
}

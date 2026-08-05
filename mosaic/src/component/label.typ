// Compact inline label.
#import "style.typ": normalize-style, styled-body, structure

/// Creates a compact inline label.
///
/// A label is a small pill that sits in the text flow rather than breaking it,
/// which suits a status tag, a version marker, or a keyword beside a heading.
///
/// ```typ
/// == Estimator #mosaic.components.label(role: "success")[stable]
/// ```
///
/// Any radius at least half the label's height rounds its ends completely, so
/// an oversized value such as `999pt` gives fully rounded pill ends. Restyle
/// the body through the `text` key of `style`.
///
/// ```typ
/// #mosaic.components.label(
///   role: "warning",
///   radius: 999pt,
///   style: (text: (weight: "bold", size: 0.7em)),
/// )[draft]
/// ```
///
/// See `frame` for the list of roles and how they resolve against the active
/// theme.
///
/// -> content
#let label(
  /// Label content, usually a word or two.
  /// -> content
  body,
  /// Semantic role name: `neutral`, `accent`, `information`, `success`,
  /// `warning`, `danger`, or `takeaway`.
  /// -> str
  role: "neutral",
  /// Corner radius. Oversize it (`999pt`) for fully rounded pill ends.
  /// -> length | dictionary
  radius: structure.label-radius,
  /// Partial style overrides, with the keys `fill`, `stroke`, `radius`,
  /// `inset`, `align`, and `text`, where `text` is a dictionary of native
  /// `text` arguments such as `size` and `weight`.
  /// -> dictionary
  style: (:),
) = context {
  let it = normalize-style(
    style: (inset: structure.label-inset) + style + (radius: radius),
    role-name: role,
    contextual: true,
  )
  box(
    fill: it.fill,
    stroke: it.stroke,
    radius: it.radius,
    inset: it.inset,
    styled-body(it, body),
  )
}

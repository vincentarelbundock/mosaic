// Compact inline label.
#import "../shared.typ": require-dictionary
#import "style.typ": normalize-style, styled-body

// Shared pill treatment: a boxed body with a large default corner radius.
#let _compact(body, role, style, radius: 999pt) = context {
  let it = normalize-style(
    style: style,
    role-name: role,
    contextual: true,
    defaults: (radius: radius, inset: (x: 0.55em, y: 0.18em)),
  )
  box(
    fill: it.fill,
    stroke: it.stroke,
    radius: it.radius,
    inset: it.inset,
    styled-body(it, body),
  )
}

/// Creates a compact inline label.
///
/// A label is a small pill that sits in the text flow rather than breaking it,
/// which suits a status tag, a version marker, or a keyword beside a heading.
///
/// ```typ
/// == Estimator #mosaic.components.label(role: "success")[stable]
/// ```
///
/// Raise `radius` for a fully rounded pill.
///
/// ```typ
/// #mosaic.components.label(
///   role: "warning",
///   radius: 999pt,
///   text-style: (weight: "bold", size: 0.7em),
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
  /// Corner radius. A large value such as `999pt` gives a fully rounded pill.
  /// -> length | dictionary
  radius: 3pt,
  /// Native `text` arguments applied to the body, such as `size` and `weight`.
  /// Merged over any `text` key in `style`.
  /// -> dictionary
  text-style: (:),
  /// Partial style overrides, with the keys `fill`, `stroke`, `radius`,
  /// `inset`, `align`, and `text`.
  /// -> dictionary
  style: (:),
) = {
  require-dictionary(text-style, "label text-style")
  let text-style = style.at("text", default: (:)) + text-style
  _compact(
    body,
    role,
    (inset: (x: 0.7em, y: 0.3em))
      + style
      + (radius: radius, text: text-style),
    radius: radius,
  )
}

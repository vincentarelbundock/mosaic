// Compact inline label.
#import "../shared.typ": require-dictionary
#import "style.typ": normalize-style, styled-body, structure

// `"pill"` names the intent that a very large radius used to spell. Numeric and
// dictionary radii pass through untouched.
#let resolve-radius(radius) = if radius == "pill" {
  structure.pill-radius
} else {
  radius
}

// Shared pill treatment: a boxed body with a large default corner radius.
#let _compact(body, role, style, radius: "pill") = context {
  let it = normalize-style(
    style: style,
    role-name: role,
    contextual: true,
    defaults: (
      radius: resolve-radius(radius),
      inset: structure.label-compact-inset,
    ),
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
/// Pass `radius: "pill"` for fully rounded ends.
///
/// ```typ
/// #mosaic.components.label(
///   role: "warning",
///   radius: "pill",
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
  /// Corner radius, or `"pill"` for fully rounded ends.
  /// -> str | length | dictionary
  radius: structure.label-radius,
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
    (inset: structure.label-inset)
      + style
      + (radius: resolve-radius(radius), text: text-style),
    radius: radius,
  )
}

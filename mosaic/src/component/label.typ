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
/// -> content
#let label(
  /// Label content.
  /// -> content
  body,
  /// Semantic role name.
  /// -> str
  role: "neutral",
  /// Corner radius.
  /// -> length | dictionary
  radius: 3pt,
  /// Native text styling arguments.
  /// -> dictionary
  text-style: (:),
  /// Component-style overrides.
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

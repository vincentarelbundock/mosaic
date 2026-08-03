// Framed callout with a semantic side stripe.
#import "style.typ": role as component-role
#import "frame.typ": frame

/// Creates a framed callout with a semantic side stripe.
///
/// -> content
#let callout(
  /// Callout content.
  /// -> content
  body,
  /// Semantic role name.
  /// -> str
  kind: "information",
  /// Optional bold title.
  /// -> content | none
  title: none,
  /// Component-style overrides.
  /// -> dictionary
  style: (:),
) = context {
  let colors = component-role(kind, contextual: true)
  frame(
    [
      #if title != none {
        text(weight: "bold", fill: colors.accent)[#title]
        parbreak()
      }
      #body
    ],
    role: kind,
    style: (
      stroke: (left: 4pt + colors.accent, rest: none),
    ) + style,
  )
}

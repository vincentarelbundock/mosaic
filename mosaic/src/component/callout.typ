// Framed callout with a semantic side stripe.
#import "style.typ": role as component-role
#import "frame.typ": frame

/// Creates a framed callout with a semantic side stripe.
///
/// A callout is a `frame` with two additions: a colored stripe down its left
/// edge, and an optional bold title in the same color. Where `frame` is a
/// neutral panel, this one announces what kind of remark it holds.
///
/// ```typ
/// #mosaic.components.callout(kind: "warning", title: [Caveat])[
///   The estimate assumes independent errors.
/// ]
/// ```
///
/// *Kinds*
///
/// - `information`: the default, and a synonym for `accent`.
/// - `success`, `warning`, `danger`: the conventional status colors.
/// - `takeaway`: reserved for conclusions.
/// - `neutral`, `accent`: the theme's own colors.
///
/// See `frame` for how roles resolve against the active theme.
///
/// -> content
#let callout(
  /// Callout content.
  /// -> content
  body,
  /// Semantic role name driving the stripe and title color: `information`,
  /// `success`, `warning`, `danger`, `takeaway`, `neutral`, or `accent`.
  /// -> str
  kind: "information",
  /// Bold title set above the body in the accent color.
  /// -> content | none
  title: none,
  /// Partial style overrides passed through to `frame`, with the keys `fill`,
  /// `stroke`, `radius`, `inset`, `align`, and `text`. Setting `stroke` replaces
  /// the side stripe.
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

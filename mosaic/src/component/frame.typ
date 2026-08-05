// Clipped, semantically styled block used as the base of other components.
#import "style.typ": validate-style, styled-body

/// Wraps content in a clipped, semantically styled block.
///
/// This is the base the other components are built on, and the one to reach for
/// when you want a panel that follows the deck's colors without spelling them
/// out.
///
/// ```typ
/// #mosaic.components.frame(role: "takeaway")[
///   The interval covers zero.
/// ]
/// ```
///
/// *Roles*
///
/// A role picks a coordinated fill, accent, and text color, so a component
/// tracks the active theme instead of hard-coding paint.
///
/// - `neutral`: the deck's own surface color. The default.
/// - `accent`, and `information` as a synonym for it: the deck's accent.
/// - `success`, `warning`, `danger`: the conventional status colors.
/// - `takeaway`: a distinct color reserved for conclusions.
///
/// `neutral` and `accent` follow the theme's resolved colors. The others are
/// fixed, colorblind-safe hues, since a warning that changed color with the
/// theme would stop reading as a warning.
///
/// *Style overrides*
///
/// `style` overrides parts of the role's treatment. Accepted keys are `fill`,
/// `stroke`, `radius`, `inset`, `align`, and `text`, where `text` is a
/// dictionary of native `text` arguments.
///
/// ```typ
/// #mosaic.components.frame(
///   style: (radius: 0pt, stroke: none, text: (size: 0.8em)),
/// )[Quiet panel]
/// ```
///
/// -> content
#let frame(
  /// Content inside the frame.
  /// -> content
  body,
  /// Semantic role name: `neutral`, `accent`, `information`, `success`,
  /// `warning`, `danger`, or `takeaway`.
  /// -> str
  role: "neutral",
  /// Partial style overrides, with the keys `fill`, `stroke`, `radius`,
  /// `inset`, `align`, and `text`.
  /// -> dictionary
  style: (:),
  /// Native block width. `auto` hugs the content.
  /// -> auto | length | relative | fraction
  width: auto,
  /// Native block height. `auto` hugs the content.
  /// -> auto | length | relative | fraction
  height: auto,
) = context {
  let it = validate-style(style: style, role-name: role, contextual: true)
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

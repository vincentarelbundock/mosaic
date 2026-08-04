// Horizontal divider, optionally split around a label.
#import "style.typ": structure, deck-colors

/// Creates a horizontal divider, optionally split around a label.
///
/// Without a label it is one full-width rule. With one, it becomes two rules
/// with the label centered between them, which is how a slide marks a change of
/// subject without spending a heading on it.
///
/// ```typ
/// #mosaic.components.divider()
///
/// #mosaic.components.divider(
///   label: text(size: 0.7em)[Robustness checks],
///   stroke: 0.5pt + luma(70%),
/// )
/// ```
///
/// -> content
#let divider(
  /// Content centered between the two line segments. `none` draws one unbroken
  /// rule instead.
  /// -> content | none
  label: none,
  /// Native Typst stroke used for both line segments. `auto` draws the deck's
  /// line color at the shared component thickness.
  /// -> auto | stroke
  stroke: auto,
) = context {
  let colors = deck-colors()
  let stroke = if stroke != auto {
    stroke
  } else if colors == none {
    structure.stroke-thickness + gray
  } else {
    structure.stroke-thickness + colors.line
  }
  grid(
    columns: if label == none { (1fr,) } else { (1fr, auto, 1fr) },
    gutter: structure.divider-gutter,
    align: horizon,
    ..if label == none {
      (line(length: 100%, stroke: stroke),)
    } else {
      (
        line(length: 100%, stroke: stroke),
        label,
        line(length: 100%, stroke: stroke),
      )
    },
  )
}

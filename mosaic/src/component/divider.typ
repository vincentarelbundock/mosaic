// Horizontal divider, optionally split around a label.

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
  /// Native Typst stroke used for both line segments.
  /// -> stroke
  stroke: 0.8pt + gray,
) = grid(
  columns: if label == none { (1fr,) } else { (1fr, auto, 1fr) },
  gutter: 0.45em,
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

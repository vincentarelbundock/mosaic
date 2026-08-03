// Horizontal divider, optionally split around a label.

/// Creates a horizontal divider, optionally split around a label.
///
/// -> content
#let divider(
  /// Optional centered label.
  /// -> content | none
  label: none,
  /// Stroke used for both line segments.
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

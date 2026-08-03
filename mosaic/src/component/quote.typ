// Quotation treatment with optional portrait and attribution.
#import "frame.typ": frame

/// Creates a quotation treatment with optional portrait and attribution.
///
/// -> content
#let quote(
  /// Quotation content.
  /// -> content
  body,
  /// Optional author or speaker.
  /// -> content | none
  attribution: none,
  /// Optional content placed beside the quotation.
  /// -> content | none
  portrait: none,
  /// Optional source appended to the attribution.
  /// -> content | none
  source: none,
  /// Semantic role name.
  /// -> str
  role: "neutral",
  /// Component-style overrides.
  /// -> dictionary
  style: (:),
) = frame(
  role: role,
  style: (
    fill: black.transparentize(94%),
    stroke: none,
  ) + style,
)[
  #grid(
    columns: if portrait == none { (1fr,) } else { (auto, 1fr) },
    gutter: 0.6em,
    ..if portrait == none { (body,) } else { (portrait, body) },
  )
  #if attribution != none or source != none {
    [#linebreak() #align(right)[
      #text(size: 0.72em)[
        #if attribution != none { attribution }
        #if attribution != none and source != none { [, ] }
        #if source != none { source }
      ]
    ]]
  }
]

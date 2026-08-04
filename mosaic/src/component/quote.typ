// Quotation treatment with optional portrait and attribution.
#import "frame.typ": frame
#import "style.typ": structure, deck-colors

/// Creates a quotation treatment with optional portrait and attribution.
///
/// The quotation sits in a lightly tinted `frame`. A portrait, when given,
/// takes a column to the left of the text; attribution and source share one
/// right-aligned line beneath it, joined by a comma when both are present.
///
/// ```typ
/// #mosaic.components.quote(
///   attribution: [Ada Lovelace],
///   source: [Notes on the Analytical Engine, 1843],
///   portrait: mosaic.components.image(
///     path("ada.webp"),
///     width: 4em, height: 4em,
///   ),
/// )[
///   The Analytical Engine weaves algebraic patterns.
/// ]
/// ```
///
/// See `frame` for the list of roles and the accepted `style` keys.
///
/// -> content
#let quote(
  /// The quoted text.
  /// -> content
  body,
  /// Who is being quoted, set on the fine-print line below the quotation.
  /// -> content | none
  attribution: none,
  /// Content placed in a column beside the quotation, typically a portrait
  /// image sized to a few `em`.
  /// -> content | none
  portrait: none,
  /// Where the quotation comes from, appended after the attribution.
  /// -> content | none
  source: none,
  /// Semantic role name: `neutral`, `accent`, `information`, `success`,
  /// `warning`, `danger`, or `takeaway`.
  /// -> str
  role: "neutral",
  /// Partial style overrides passed through to `frame`, with the keys `fill`,
  /// `stroke`, `radius`, `inset`, `align`, and `text`.
  /// -> dictionary
  style: (:),
) = context {
  // The wash is the deck's own text color laid over the canvas, not a fixed
  // black: on a dark deck a black wash is invisible, while a wash of the text
  // color reads as the same faint lift in either direction. Pass `fill` in
  // `style` to replace it outright.
  let colors = deck-colors()
  let wash = if colors == none { black } else { colors.text }
  frame(
    role: role,
    style: (
      fill: wash.transparentize(structure.quote-wash),
      stroke: none,
    ) + style,
  )[
    #grid(
      columns: if portrait == none { (1fr,) } else { (auto, 1fr) },
      gutter: structure.quote-gutter,
      ..if portrait == none { (body,) } else { (portrait, body) },
    )
    #if attribution != none or source != none {
      // `block(above:)` rather than a `linebreak()` followed by block-level
      // content: that stacked an empty line on top of the paragraph break before
      // the block, leaving the attribution floating far below the quotation.
      block(above: structure.quote-attribution-gap, width: 100%, align(right)[
        #text(size: structure.quote-attribution-size)[
          #if attribution != none { attribution }
          #if attribution != none and source != none { [, ] }
          #if source != none { source }
        ]
      ])
    }
  ]
}

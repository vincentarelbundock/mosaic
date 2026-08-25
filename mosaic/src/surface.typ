// Native show-rule shorthand for painting labeled cell and plane blocks.

/// Builds the transforming rule that paints a cell's or plane's own block.
///
/// Properties of the content inside a cell, such as text, alignment, and
/// paragraphs, reach it through ordinary `set` rules on its label. The cell's
/// own surface cannot, because it is a block constructed before those rules
/// apply, so it is painted by wrapping the labeled block instead. `surface`
/// returns that standard wrapper, `it => block(width: 100%, height: auto, ...,
/// it)`, ready to use as the body of a label rule.
///
/// ```typ
/// #show label("mosaic-cell-body"): mosaic.surface(
///   fill: luma(240),
///   stroke: 0.5pt + gray,
///   radius: 6pt,
///   height: 100%,
/// )
/// ```
///
/// *What it applies to*
///
/// - Any grid cell, through its `<mosaic-cell-ID>` label.
/// - The full-slide planes, which carry `<mosaic-background>` and
///   `<mosaic-foreground>`.
///
/// Both kinds of rule may be combined with ordinary `set` rules on the same
/// label; the `set` rule styles the content and this one paints the block
/// around it.
///
/// -> function
#let surface(
  /// Paint behind the content, or `none`.
  /// -> none | color | gradient | tiling
  fill: none,
  /// Border drawn around the painted block, or `none`.
  /// -> none | length | color | gradient | stroke | tiling | dictionary
  stroke: none,
  /// Corner radius of the painted block.
  /// -> relative | dictionary
  radius: 0pt,
  /// Height of the painted block. `auto` sizes it to the content, which is
  /// what a cell in an `auto` track wants. Pass `100%` for a cell in a `1fr`
  /// or fixed track, or for a plane, to fill the region edge to edge.
  /// -> auto | relative
  height: auto,
) = it => block(
  width: 100%,
  height: height,
  fill: fill,
  stroke: stroke,
  radius: radius,
  it,
)

// Native show-rule shorthand for painting labeled cell and plane blocks.

/// Builds the transforming rule that paints a cell's or plane's own block.
///
/// Properties of the content inside a cell (text, alignment, paragraphs)
/// reach it through ordinary `set` rules on its label. The cell's own surface
/// cannot, because it is a block constructed before those rules apply, so it
/// is painted by wrapping the labeled block instead. `surface` returns that
/// standard wrapper, `it => block(width: 100%, height: 100%, ..., it)`, ready
/// to use as the body of a label rule:
///
/// ```typ
/// #show label("mosaic-cell-body"): surface(fill: luma(240))
/// ```
///
/// The full-slide planes carry the labels `<mosaic-background>` and
/// `<mosaic-foreground>`, so the same rule paints them.
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
  /// Height of the painted block. Keep `100%` for cells in `1fr` or fixed
  /// tracks; pass `auto` for a content-sized cell in an `auto` track so the
  /// paint hugs the content.
  /// -> auto | relative
  height: 100%,
) = it => block(
  width: 100%,
  height: height,
  fill: fill,
  stroke: stroke,
  radius: radius,
  it,
)

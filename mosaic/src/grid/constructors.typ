// Public and internal constructors for canonical grid nodes.
#import "../shared.typ": tag, fail
#import "model.typ": (
  plane-ids, is-node, is-track, split-name,
  valid-rule, valid-track-size,
)
#import "validation.typ": validate

#let resolve-cell-id(identifier, id, name) = {
  if identifier.named().len() > 0 {
    fail(name + " accepts only a cell id and optional fixed content")
  }
  let positional = identifier.pos()
  if positional.len() > 1 {
    fail(name + " accepts at most one positional argument, the cell id")
  }
  let resolved = if positional.len() == 1 {
    if id != none {
      fail("cell id must be passed positionally or through id:, not both")
    }
    positional.first()
  } else {
    id
  }
  if type(resolved) != str or resolved == "" {
    fail("cell id must be a non-empty string")
  }
  if resolved in plane-ids {
    fail("cell id " + repr(resolved) + " is reserved for the " + resolved + " plane")
  }
  resolved
}

// Internal cell constructor used by layout resolvers and setup defaults.
#let styled-cell(
  ..identifier,
  content: none,
  style: (:),
  id: none,
) = {
  let id = resolve-cell-id(identifier, id, "styled-cell")
  if type(style) != dictionary {
    fail("styled-cell style must be a dictionary")
  }
  // `auto` defers the inset to render time, where `settings.spacing.inset` is
  // readable. Injecting a literal here would silently outrank the configured
  // token, since a cell that leaves `inset` at `auto` contributes no key of its
  // own. The key is always present so an otherwise-bare cell still carries a
  // style and reaches `render-cell`.
  (
    mosaic: tag,
    kind: "cell",
    content: content,
    style: (inset: auto) + style,
    id: id,
  )
}

/// Creates a structural leaf cell in a Mosaic grid tree.
///
/// A cell is where slide content lands. Its id must be a non-empty string,
/// unique within the tree, and may not be one of the reserved plane ids
/// `background` or `foreground`. Pass it positionally or through `id:`, but
/// not both.
///
/// ```typ
/// #mosaic.grid.v(
///   mosaic.grid.t(auto, mosaic.grid.cell("header")),
///   mosaic.grid.cell("body"),
/// )
/// ```
///
/// *Styling*
///
/// Cells are structural only. Every rendered cell is labeled
/// `<mosaic-cell-ID>`, so appearance comes from native Typst rules. Use a `set`
/// rule for properties of the content and `mosaic.surface` for the cell's own
/// block.
///
/// ```typ
/// #show label("mosaic-cell-body"): set text(size: 0.9em)
/// #show label("mosaic-cell-body"): mosaic.surface(fill: luma(240))
/// ```
///
/// -> dictionary
#let cell(
  /// The cell id, as the sole positional argument. Give it here or through
  /// `id:`.
  /// -> arguments
  ..identifier,
  /// Fixed content rendered in place of a slide body, so the surrounding slide
  /// supplies no block for this cell.
  /// -> content | none
  content: none,
  /// The cell id, when it is not passed positionally.
  /// -> str | none
  id: none,
  /// Native Typst inset applied inside the cell's labeled block. `auto` uses
  /// the `spacing.inset` configured on `setup`.
  /// -> auto | length | relative | dictionary
  inset: auto,
) = {
  if identifier.named().len() > 0 {
    fail("cell accepts only a cell id, optional fixed content, and inset")
  }
  let id = resolve-cell-id(identifier, id, "cell")
  styled-cell(
    id: id,
    content: content,
    style: if inset == auto { (:) } else { (inset: inset) },
  )
}

/// Associates an explicit native track size with one child of `h` or `v`.
///
/// Unwrapped children of a split take `1fr` and therefore share the space
/// evenly. Wrap one in `t` to give it a size of its own.
///
/// ```typ
/// #mosaic.grid.v(
///   mosaic.grid.t(auto, "header"),   // as tall as its content
///   "body",                          // 1fr, taking the rest
///   mosaic.grid.t(2em, "footer"),    // a fixed strip
/// )
/// ```
///
/// The wrapper is temporary: `h` or `v` unwraps it while constructing the
/// split, so a `t` value never appears in a resolved tree.
///
/// -> dictionary
#let t(
  /// Native Typst grid track size. `auto` sizes to the child's content, a
  /// length or ratio fixes it, and a fraction such as `2fr` takes a share of
  /// what remains.
  /// -> auto | length | ratio | relative | fraction
  size,
  /// The child to size: a string cell id, or a canonical Mosaic grid node built
  /// with `cell`, `h`, or `v`.
  /// -> str | dictionary
  child,
) = {
  if not valid-track-size(size) {
    fail(
      "t size must be auto, a fixed or relative length, or a fractional length",
    )
  }
  (
    mosaic: tag,
    kind: "track",
    size: size,
    child: child,
  )
}

// Canonical branch constructor. Public callers use mosaic.grid.h() and
// mosaic.grid.v().
#let split(
  axis,
  tracks: auto,
  gutter: 0pt,
  rule: none,
  ..children,
) = {
  let name = split-name(axis)
  let children = children.pos()
  if axis not in ("width", "height") {
    fail("split axis must be \"width\" or \"height\"")
  }
  if children.len() == 0 {
    fail(name + " must contain at least one child")
  }
  if not children.all(is-node) {
    fail(name + " children must be Mosaic grid nodes")
  }
  if not valid-track-size(gutter) {
    fail(name + " gutter must be a native Typst track size")
  }
  if not valid-rule(rule) {
    fail(name + " rule must be none or a native Typst stroke")
  }
  if tracks != auto and (
    type(tracks) != array
      or tracks.len() != children.len()
      or not tracks.all(valid-track-size)
  ) {
    fail(
      name + " tracks must contain one native Typst track size per child",
    )
  }
  let result = (
    mosaic: tag,
    kind: "split",
    axis: axis,
    tracks: tracks,
    gutter: gutter,
    rule: rule,
    children: children,
  )
  validate(result)
  result
}

#let normalize-split-child(value) = {
  let size = 1fr
  let child = value
  if is-track(value) {
    size = value.size
    child = value.child
  }
  if type(child) == str {
    child = cell(id: child)
  } else if not is-node(child) {
    fail("h/v children must be string cell IDs or Mosaic grid nodes")
  }
  (size, child)
}

#let split-node(axis, gutter, rule, children) = {
  let name = split-name(axis)
  if children.len() == 0 {
    fail(name + " must contain at least one child")
  }
  let parts = children.map(normalize-split-child)
  let tracks = parts.map(part => part.at(0))
  let nodes = parts.map(part => part.at(1))
  split(axis, tracks: tracks, gutter: gutter, rule: rule, ..nodes)
}

/// Splits the available width, arranging its children as columns.
///
/// Children may be given in three forms, freely mixed:
///
/// - A string, which is shorthand for `cell(id)`.
/// - A node built with `cell`, `h`, or `v`, so splits nest to any depth.
/// - Any of those wrapped in `t` to give it an explicit track size.
///
/// Each unwrapped child receives a `1fr` column, so an unadorned `h` divides
/// the width evenly.
///
/// ```typ
/// #mosaic.grid.h(
///   gutter: 1em,
///   rule: 0.5pt + gray,
///   mosaic.grid.t(2fr, "left"),
///   "right",
/// )
/// ```
///
/// -> dictionary
#let h(
  /// Native Typst track size used between adjacent columns.
  /// -> auto | length | ratio | relative | fraction
  gutter: 0pt,
  /// Stroke drawn along each interior column boundary, centered in the gutter.
  /// A gutter of `0pt` leaves the rule sitting directly between the columns.
  /// -> none | stroke
  rule: none,
  /// The columns: string cell ids, Mosaic grid nodes, or values wrapped with
  /// `t`. At least one is required.
  /// -> arguments
  ..children,
) = split-node("width", gutter, rule, children.pos())

/// Splits the available height, arranging its children as rows.
///
/// Children take the same three forms as in `h`: a string cell id, a Mosaic
/// grid node, or either wrapped in `t`. Each unwrapped child receives a `1fr`
/// row.
///
/// ```typ
/// #mosaic.grid.v(
///   gutter: 0.7em,
///   mosaic.grid.t(auto, "header"),
///   mosaic.grid.h(gutter: 1em, "left", "right"),
///   mosaic.grid.t(auto, "footer"),
/// )
/// ```
///
/// -> dictionary
#let v(
  /// Native Typst track size used between adjacent rows.
  /// -> auto | length | ratio | relative | fraction
  gutter: 0pt,
  /// Stroke drawn along each interior row boundary, centered in the gutter.
  /// -> none | stroke
  rule: none,
  /// The rows: string cell ids, Mosaic grid nodes, or values wrapped with `t`.
  /// At least one is required.
  /// -> arguments
  ..children,
) = split-node("height", gutter, rule, children.pos())



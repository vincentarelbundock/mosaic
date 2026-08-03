// Public and internal constructors for canonical grid nodes.
#import "../shared.typ": tag, fail
#import "model.typ": (
  plane-ids, fit-modes, is-node, is-track, split-name,
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

#let validate-fit(value, name) = {
  if value not in fit-modes {
    fail(
      name + " fit must be none, \"auto\", \"width\", or \"contain\", not "
        + repr(value),
    )
  }
  value
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
  (
    mosaic: tag,
    kind: "cell",
    content: content,
    style: (inset: 1.25em) + style,
    id: id,
  )
}

/// Creates a structural leaf cell in a Mosaic grid tree.
///
/// Cells are structural only. Every rendered cell is labeled
/// `<mosaic-cell-ID>`, so appearance is supplied with native Typst rules:
/// `show label("mosaic-cell-" + id): set text(...)`.
///
/// `fit` shrinks content that would otherwise overflow the cell rather than
/// letting it spill: `"width"` scales to the cell width, `"contain"` scales to
/// the cell height, and `"auto"` scales to the height and reflows at the
/// smaller size. The default `none` leaves content at its natural size, where
/// overflow observation reports it instead.
///
/// -> dictionary
#let cell(
  /// Required stable name used to identify the cell, as the sole positional
  /// argument or through `id:`.
  /// -> str
  ..identifier,
  /// Optional fixed content rendered instead of a slide body.
  /// -> content | none
  content: none,
  /// Required stable name used to identify the cell when it is not passed
  /// positionally.
  /// -> str
  id: none,
  /// Native Typst inset applied inside the cell's labeled block, or `auto`
  /// for the Mosaic default.
  /// -> auto | length | relative | dictionary
  inset: auto,
  /// Shrink-to-fit mode: `none`, `"width"`, `"contain"`, or `"auto"`.
  /// -> none | str
  fit: none,
) = {
  if identifier.named().len() > 0 {
    fail("cell accepts only a cell id, optional fixed content, inset, and fit")
  }
  let id = resolve-cell-id(identifier, id, "cell")
  let _ = validate-fit(fit, "cell " + repr(id))
  styled-cell(
    id: id,
    content: content,
    style: (
      if inset == auto { (:) } else { (inset: inset) }
    ) + if fit == none { (:) } else { (fit: fit) },
  )
}

/// Associates an explicit native track size with one child of `h` or `v`.
///
/// This wrapper is temporary: `h` or `v` removes it while constructing a
/// split. Unwrapped children use `1fr`.
///
/// -> dictionary
#let t(
  /// Native Typst grid track size.
  /// -> auto | length | ratio | relative | fraction
  size,
  /// String cell ID or canonical Mosaic grid node.
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

/// Arranges string cell IDs or Mosaic grid nodes horizontally.
///
/// Each unwrapped child receives a `1fr` column. Wrap a child with `t` to use
/// another native track size.
///
/// -> dictionary
#let h(
  /// Native Typst track size used between adjacent columns.
  /// -> auto | length | ratio | relative | fraction
  gutter: 0pt,
  /// Stroke drawn along each interior column boundary, centered in the
  /// gutter, or `none`.
  /// -> none | stroke
  rule: none,
  /// String cell IDs, grid nodes, or values wrapped with `t`.
  /// -> arguments
  ..children,
) = split-node("width", gutter, rule, children.pos())

/// Arranges string cell IDs or Mosaic grid nodes vertically.
///
/// Each unwrapped child receives a `1fr` row. Wrap a child with `t` to use
/// another native track size.
///
/// -> dictionary
#let v(
  /// Native Typst track size used between adjacent rows.
  /// -> auto | length | ratio | relative | fraction
  gutter: 0pt,
  /// Stroke drawn along each interior row boundary, centered in the gutter,
  /// or `none`.
  /// -> none | stroke
  rule: none,
  /// String cell IDs, grid nodes, or values wrapped with `t`.
  /// -> arguments
  ..children,
) = split-node("height", gutter, rule, children.pos())



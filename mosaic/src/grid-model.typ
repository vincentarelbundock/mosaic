// Mosaic cell/split nodes, validation, and traversal.
#import "shared.typ": tag, fail
#import "incremental-core.typ": parse-range, validate-state

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
  resolved
}

// Internal cell constructor used by template resolvers and setup defaults.
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
/// Visual properties are supplied by stable cell ID through
/// `slide(cell-styles: ...)`.
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
) = {
  if identifier.named().len() > 0 {
    fail("cell visual fields belong in slide cell-styles")
  }
  let id = resolve-cell-id(identifier, id, "cell")
  styled-cell(id: id, content: content)
}

#let public-cell-style-fields = (
  "align", "background", "fill", "fit", "inset", "radius", "stroke", "text",
)

#let validate-cell-styles(styles) = {
  if type(styles) != dictionary {
    fail("slide cell-styles must be a dictionary")
  }
  for (id, style) in styles {
    if type(style) != dictionary {
      fail("slide cell style for " + repr(id) + " must be a dictionary")
    }
    let unsupported = style.keys().find(
      key => key not in public-cell-style-fields,
    )
    if unsupported != none {
      fail(
        "slide cell style for " + repr(id)
          + " has unsupported field " + repr(unsupported),
      )
    }
    if "text" in style and type(style.text) != dictionary {
      fail("slide cell style text for " + repr(id) + " must be a dictionary")
    }
    if "fit" in style and style.fit not in (none, "auto", "width", "contain") {
      fail(
        "slide cell style fit for " + repr(id)
          + " must be none, \"auto\", \"width\", or \"contain\"",
      )
    }
    if "background" in style and (
      style.background != none and type(style.background) != content
    ) {
      fail(
        "slide cell style background for " + repr(id)
          + " must be content or none",
      )
    }
  }
  styles
}

#let valid-track-size(size) = (
  size == auto
    or type(size) in (
      type(1fr),
      type(1pt),
      type(1%),
      type(1% + 1pt),
    )
)

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

#let is-core-node(node) = (
  type(node) == dictionary
    and node.at("mosaic", default: none) == tag
    and node.at("kind", default: none) in ("cell", "split")
)

#let is-on-node(node) = (
  type(node) == dictionary
    and node.at("mosaic", default: none) == tag
    and node.at("kind", default: none) == "on"
)

#let is-node(node) = is-core-node(node) or is-on-node(node)

#let is-track(value) = (
  type(value) == dictionary
    and value.keys().sorted() == ("child", "kind", "mosaic", "size")
    and value.mosaic == tag
    and value.kind == "track"
)

#let collect-cell-ids(node) = {
  if node.kind == "cell" {
    (node.id,)
  } else if node.kind == "on" {
    collect-cell-ids(node.child)
  } else {
    node.children.map(collect-cell-ids).flatten()
  }
}

#let require-unique-cell-ids(node, path: "root") = {
  let ids = collect-cell-ids(node)
  if ids.dedup().len() != ids.len() {
    let duplicate = ids.find(id => ids.filter(other => other == id).len() > 1)
    fail("duplicate cell id " + repr(duplicate) + " in grid at " + path)
  }
}

#let split-name(axis) = if axis == "width" { "h" } else { "v" }

#let valid-cell-style(style) = (
  type(style) == dictionary
    and "inset" in style
    and style.keys().all(
      key => key in (
        "after", "align", "background", "before", "content-sized", "fill",
        "fit", "inset", "radius", "stroke", "text", "_fit-reserve", "_fit-width",
      ),
    )
    and type(style.at("text", default: (:))) == dictionary
    and type(style.at("before", default: [])) == content
    and type(style.at("after", default: [])) == content
    and style.at("fit", default: none) in (none, "auto", "width", "contain")
    and style.at("_fit-width", default: auto) in (auto, 50%)
    and (
      style.at("_fit-reserve", default: none) == none
        or type(style._fit-reserve) == content
    )
    and (
      style.at("background", default: none) == none
        or type(style.background) == content
    )
    and type(style.at("content-sized", default: false)) == bool
)

#let valid-node-shape(node) = {
  if type(node) != dictionary {
    false
  } else {
    let keys = node.keys().sorted()
    let valid-tag = node.at("mosaic", default: none) == tag
    let valid-kind = (
      node.at("kind", default: none) in ("cell", "split", "on")
    )
    let cell-fields = (
      node.at("kind", default: none) == "cell"
        and keys == ("content", "id", "kind", "mosaic", "style")
        and (
          node.content == none
            or type(node.content) == content
        )
        and type(node.id) == str
        and node.id != ""
        and valid-cell-style(node.style)
    )
    let split-fields = (
      node.at("kind", default: none) == "split"
        and keys == (
          "axis", "children", "gutter", "kind", "mosaic", "rule", "tracks",
        )
        and node.axis in ("width", "height")
        and type(node.children) == array
        and valid-track-size(node.gutter)
    )
    let on-fields = (
      node.at("kind", default: none) == "on"
        and keys == ("after", "before", "child", "kind", "mosaic", "range")
    )
    valid-tag and valid-kind and (cell-fields or split-fields or on-fields)
  }
}

#let validate-shape(node, path: "root") = {
  if not valid-node-shape(node) {
    fail("invalid grid node at " + path)
  }
  if node.kind == "on" {
    _ = parse-range(node.range)
    validate-state(node.before, "before")
    validate-state(node.after, "after")
    validate-shape(node.child, path: path + ".child")
  } else if node.kind != "cell" {
    if node.children.len() == 0 {
      fail(
        split-name(node.axis) + " at " + path
          + " must contain at least one child",
      )
    }
    if node.tracks != auto and (
      type(node.tracks) != array
        or node.tracks.len() != node.children.len()
        or not node.tracks.all(valid-track-size)
    ) {
      fail(
        split-name(node.axis) + " at " + path
          + " must contain one native Typst track size per child",
      )
    }
    for (index, child) in node.children.enumerate() {
      validate-shape(child, path: path + ".children[" + str(index) + "]")
    }
  }
}

#let validate(node, path: "root") = {
  validate-shape(node, path: path)
  require-unique-cell-ids(node, path: path)
}

#let apply-cell-styles(node, styles) = {
  let styles = validate-cell-styles(styles)
  let ids = collect-cell-ids(node)
  let unknown = styles.keys().find(id => id not in ids)
  if unknown != none {
    fail("slide cell-styles contains unknown cell id " + repr(unknown))
  }
  let apply(node) = if node.kind == "cell" {
    if node.id not in styles {
      node
    } else {
      let override = styles.at(node.id)
      let merged = node.style + override
      if "text" in override {
        merged.insert(
          "text",
          node.style.at("text", default: (:)) + override.text,
        )
      }
      node + (style: merged)
    }
  } else if node.kind == "on" {
    node + (child: apply(node.child))
  } else {
    node + (children: node.children.map(apply))
  }
  let result = apply(node)
  validate(result)
  result
}

#let valid-rule(value) = (
  value == none
    or type(value) in (
      length,
      color,
      gradient,
      tiling,
      dictionary,
      stroke,
    )
)

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

#let fold-grid(node, visit-cell, visit-on, visit-branch) = {
  if node.kind == "cell" {
    visit-cell(node)
  } else if node.kind == "on" {
    visit-on(
      node,
      fold-grid(node.child, visit-cell, visit-on, visit-branch),
    )
  } else {
    visit-branch(
      node,
      node.children.map(child => fold-grid(
        child,
        visit-cell,
        visit-on,
        visit-branch,
      )),
    )
  }
}

#let count-matching-cells(node, matches) = fold-grid(
  node,
  cell => if matches(cell) { 1 } else { 0 },
  (node, child) => child,
  (node, children) => children.sum(),
)

#let count-bodies(node) = count-matching-cells(
  node,
  cell => cell.content == none,
)

#let resolved-tracks(node) = if node.tracks == auto {
  (1fr,) * node.children.len()
} else {
  node.tracks
}

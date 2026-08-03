// Validation of canonical grid trees.
#import "../shared.typ": fail, tag
#import "../incremental/core.typ": parse-range, validate-states
#import "model.typ": fit-modes, split-name, valid-track-size
#import "traversal.typ": collect-cell-ids

#let require-unique-cell-ids(node, path: "root") = {
  let ids = collect-cell-ids(node)
  if ids.dedup().len() != ids.len() {
    let duplicate = ids.find(id => ids.filter(other => other == id).len() > 1)
    fail("duplicate cell id " + repr(duplicate) + " in grid at " + path)
  }
}

#let valid-cell-style(style) = (
  type(style) == dictionary
    and "inset" in style
    and style.keys().all(
      key => key in (
        "after", "background", "before", "content-sized", "fill",
        "fit", "inset", "radius", "stroke",
      ),
    )
    and type(style.at("before", default: [])) == content
    and type(style.at("after", default: [])) == content
    and style.at("fit", default: none) in fit-modes
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
    validate-states(node.before, node.after)
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



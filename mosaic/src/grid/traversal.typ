// Grid-tree traversal and structural queries.

#let collect-cell-ids(node) = {
  if node.kind == "cell" {
    (node.id,)
  } else if node.kind == "on" {
    collect-cell-ids(node.child)
  } else {
    node.children.map(collect-cell-ids).flatten()
  }
}

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

#let resolved-tracks(node) = if node.tracks == auto {
  (1fr,) * node.children.len()
} else {
  node.tracks
}


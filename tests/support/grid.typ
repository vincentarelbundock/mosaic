// Test-only inspection helpers. Public callers construct grids with h/v/cell/t.
#import "../../mosaic/src/grid-model.typ": (
  validate,
  count-bodies,
  resolved-tracks,
)

#let count-cells(node) = if node.kind == "cell" {
  1
} else if node.kind == "on" {
  count-cells(node.child)
} else {
  node.children.map(count-cells).sum()
}

#let cell-ids(node) = if node.kind == "cell" {
  (node.id,)
} else if node.kind == "on" {
  cell-ids(node.child)
} else {
  node.children.map(cell-ids).flatten()
}

#let cell-id-positions(node, id, start: 0) = {
  if node.kind == "cell" {
    if node.id == id { (start,) } else { () }
  } else if node.kind == "on" {
    cell-id-positions(node.child, id, start: start)
  } else {
    let matches = ()
    let next = start
    for child in node.children {
      matches += cell-id-positions(child, id, start: next)
      next += count-cells(child)
    }
    matches
  }
}

#let cell-position(grid, id) = {
  assert(type(id) == str, message: "test cell selector must be a string")
  let matches = cell-id-positions(grid, id)
  assert(matches.len() == 1, message: "test cell selector must be unique")
  matches.first()
}

#let inspect-cell(
  node,
  target,
  start: 0,
  path: (),
  tracks: (),
) = {
  if node.kind == "cell" {
    return (
      path: path,
      cell: node,
      tracks: tracks,
    )
  }
  if node.kind == "on" {
    return inspect-cell(
      node.child,
      target,
      start: start,
      path: path,
      tracks: tracks,
    )
  }

  let next = start
  for (child-index, child) in node.children.enumerate() {
    let child-count = count-cells(child)
    if target >= next and target < next + child-count {
      let track = (
        axis: node.axis,
        path: path,
        child: child-index,
        value: resolved-tracks(node).at(child-index),
        affects: cell-ids(child),
      )
      return inspect-cell(
        child,
        target,
        start: next,
        path: path + (child-index,),
        tracks: tracks + (track,),
      )
    }
    next += child-count
  }
}

#let info(grid, id) = {
  validate(grid)
  let inspected = inspect-cell(grid, cell-position(grid, id))
  (
    id: id,
    path: inspected.path,
    cell: inspected.cell,
    tracks: inspected.tracks,
  )
}

#let count(grid) = {
  validate(grid)
  count-cells(grid)
}

#let bodies(grid) = {
  validate(grid)
  count-bodies(grid)
}

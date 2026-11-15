// Slide-content routing for canonical grid trees.
#import "../shared.typ": fail
#import "traversal.typ": resolve-cell-ids, fold-grid

// The IDs of every content-bearing cell (content == none), in the same
// depth-first declaration order that positional bodies fill. This is the
// single ordered destination list; named content is normalized against it.
#let body-cell-ids(node) = fold-grid(
  node,
  cell => if cell.content == none { (cell.id,) } else { () },
  (node, child) => child,
  (node, children) => children.flatten(),
)

// Resolve a slide's content into one id -> content map, the single internal
// representation the renderer consumes. Setup defaults are fallbacks for
// content-bearing cells that exist in this resolved grid. Named slide content
// overrides those defaults; `none` explicitly suppresses one.
//
// Cells named in `cells:` are filled from it first and leave the pool. The
// positional bodies then fill the cells that remain, in depth-first layout
// order, starting with the first: the header, the footer, and cells with a
// deck default are filled like any other, and a body's content is never
// read. Fewer bodies than cells leaves the trailing cells to their deck
// default, or empty; more is an error; none at all is an empty slide.
//
// `none` means "suppress", so suppressing a cell this layout does not have is
// already true and resolves to a no-op. That matches a setup-level default for
// an absent cell, which is likewise ignored, and it lets one slide say
// `footer: none` across layouts that do not all carry a footer. Any non-`none`
// value for an unknown id is still an error: there the author is supplying
// content that would silently vanish.
#let resolve-content(node, named, bodies, defaults: (:)) = {
  let body-ids = body-cell-ids(node)
  let inherited = (:)
  for id in body-ids {
    if id in defaults {
      let value = defaults.at(id)
      inherited.insert(id, if value == none { [] } else { value })
    }
  }
  // Named content first: each cell `cells:` names is filled from it and
  // leaves the positional pool.
  let all-ids = resolve-cell-ids(node)
  let explicit = (:)
  for (id, value) in named {
    if id not in all-ids {
      if value == none { continue }
      fail("slide cells contains unknown cell id " + repr(id))
    }
    // A fixed-content cell is a different case: the cell does exist, so
    // `none` there reads as "blank it", which the layout cannot honor.
    // Keeping the error surfaces that rather than silently ignoring it.
    if id not in body-ids {
      fail("slide cells cannot supply fixed-content cell " + repr(id))
    }
    if value != none and type(value) != content {
      fail("slide cells for " + repr(id) + " must be content or none")
    }
    explicit.insert(id, if value == none { [] } else { value })
  }
  // Then the positional bodies, in order, over the cells that remain.
  let remaining = body-ids.filter(id => id not in explicit)
  if bodies.len() > remaining.len() {
    let cells = if remaining.len() == 1 { " cell" } else { " cells" }
    fail(
      "slide received " + str(bodies.len()) + " positional "
        + (if bodies.len() == 1 { "body" } else { "bodies" })
        + ", but this layout has "
        + (
          if remaining.len() == 0 { "no cells" } else { str(remaining.len()) + cells }
        )
        + (if explicit.len() > 0 { " not named in cells:" } else { "" })
        + " to fill"
        + (
          if remaining.len() == 0 { "" } else {
            ": " + remaining.map(repr).join(", ")
          }
        ),
    )
  }
  let destination-ids = remaining.slice(0, bodies.len())
  let resolved = inherited + explicit
  for (index, id) in destination-ids.enumerate() {
    resolved.insert(id, bodies.at(index))
  }
  for id in body-ids {
    if id not in resolved {
      resolved.insert(id, [])
    }
  }
  resolved
}

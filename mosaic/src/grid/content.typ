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

// The one cell positional bodies never fill. A footer is deck furniture that
// recurs from slide to slide, so it is reached by name: on the slide through
// `cells: (footer: ..)`, deck-wide through `setup(cells: (footer: ..))`.
#let footer-id = "footer"

// Resolve a slide's content into one id -> content map, the single internal
// representation the renderer consumes. Setup defaults are fallbacks for
// content-bearing cells that exist in this resolved grid. Named slide content
// overrides those defaults; `none` explicitly suppresses one.
//
// Positional bodies are routed by their count alone; their content is never
// read. The fillable cells are the content-bearing cells other than the
// footer, in depth-first layout order. A slide gives either one body for each
// fillable cell without a deck default, which leaves the defaults in place,
// or one body for every fillable cell, which overrides them. The `header`
// cell always carries a default (setup injects one), so on a header-and-body
// layout one body fills the body and two fill the header and the body. Any
// other count is an error, except zero: an empty slide is allowed. Any
// omitted content-bearing cell becomes [].
//
// `none` means "suppress", so suppressing a cell this layout does not have is
// already true and resolves to a no-op. That matches a setup-level default for
// an absent cell, which is likewise ignored, and it lets one slide say
// `footer: none` across layouts that do not all carry a footer. Any non-`none`
// value for an unknown id is still an error: there the author is supplying
// content that would silently vanish.
// One message for too many and too few: the count received, the cells each
// accepted count fills, and the way to reach any other cell.
#let positional-count-error(count, undefaulted, fillable, body-ids) = {
  let describe(ids) = (
    str(ids.len()) + " (" + ids.map(repr).join(", ") + ")"
  )
  let accepted = if fillable.len() == 0 {
    "no positional bodies"
  } else if undefaulted.len() == 0 or undefaulted.len() == fillable.len() {
    describe(fillable)
  } else {
    describe(undefaulted) + " or " + describe(fillable)
  }
  let others = body-ids.filter(id => id not in fillable)
  (
    "slide received " + str(count) + " positional "
      + (if count == 1 { "body" } else { "bodies" })
      + "; this layout takes " + accepted
      + (
        if others.len() > 0 {
          (
            "; fill other cells such as " + others.map(repr).join(", ")
              + " by name through cells:"
          )
        } else {
          "; or fill its cells by name through cells:"
        }
      )
  )
}

#let resolve-content(node, named, bodies, defaults: (:)) = {
  let body-ids = body-cell-ids(node)
  let inherited = (:)
  for id in body-ids {
    if id in defaults {
      let value = defaults.at(id)
      inherited.insert(id, if value == none { [] } else { value })
    }
  }
  if named.len() > 0 {
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
    let resolved = inherited + explicit
    for id in body-ids {
      if id not in resolved {
        resolved.insert(id, [])
      }
    }
    resolved
  } else {
    let fillable = body-ids.filter(id => id != footer-id)
    let undefaulted = fillable.filter(id => id not in inherited)
    let destination-ids = if bodies.len() == 0 {
      ()
    } else if bodies.len() == undefaulted.len() {
      undefaulted
    } else if bodies.len() == fillable.len() {
      fillable
    } else {
      fail(positional-count-error(bodies.len(), undefaulted, fillable, body-ids))
    }
    let resolved = inherited
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
}

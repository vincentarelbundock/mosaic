// Slide-content routing for canonical grid trees.
#import "../shared.typ": fail
#import "traversal.typ": resolve-cell-ids, fold-grid
#import "../opening-heading.typ": split-opening-heading

// The IDs of every content-bearing cell (content == none), in the same
// depth-first declaration order that positional bodies fill. This is the
// single ordered destination list; named content is normalized against it.
#let body-cell-ids(node) = fold-grid(
  node,
  cell => if cell.content == none { (cell.id,) } else { () },
  (node, child) => child,
  (node, children) => children.flatten(),
)

// The cell a slide's opening heading fills.
#let header-id = "header"

// Resolve a slide's content into one id -> content map, the single internal
// representation the renderer consumes. Setup defaults are fallbacks for
// content-bearing cells that exist in this resolved grid. Named slide content
// overrides those defaults; `none` explicitly suppresses one.
//
// Positional bodies follow one rule, whatever their count. A slide's opening
// heading is its header: when the layout has a `header` cell and the first
// body opens with a heading, that heading fills the header, as the heading of
// an automatic slide does. Everything else fills, in layout order, the cells
// that have no deck default and are not the header; those cells are addressed
// by name through `cells:`. Any omitted content-bearing cell becomes [].
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
    let destination-ids = body-ids.filter(
      id => id not in inherited and id != header-id,
    )
    let resolved = inherited
    let bodies = bodies
    let lifted = false
    if header-id in body-ids and bodies.len() > 0 {
      let opening = split-opening-heading(bodies.first())
      if opening.heading != none {
        lifted = true
        resolved.insert(header-id, opening.heading)
        bodies = bodies.slice(1)
        if opening.rest != none {
          bodies.insert(0, opening.rest)
        }
      }
    }
    if bodies.len() > destination-ids.len() {
      fail(
        "slide received " + str(bodies.len()) + " positional "
          + (if bodies.len() == 1 { "body" } else { "bodies" })
          + ", but on this layout they fill "
          + (
            if destination-ids.len() == 0 { "no cell" } else {
              destination-ids.map(repr).join(", ", last: " and ")
            }
          )
          + "; address any other cell by name through cells:"
          // The likeliest cause on a layout with a header: a first body meant
          // for it that is not a heading. Say what would have worked.
          + (
            if header-id in body-ids and not lifted {
              (
                ". A first body that opens with a heading fills the header; "
                  + "other header content goes through cells: (header: ..)"
              )
            } else { "" }
          ),
      )
    }
    for (index, id) in destination-ids.enumerate() {
      resolved.insert(id, bodies.at(index, default: []))
    }
    resolved
  }
}

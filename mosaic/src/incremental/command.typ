// Public incremental constructors and canonical deferred records.
#import "../shared.typ": tag, fail, typst-sequence
#import "core.typ": (
  parse-positive-int,
  parse-range,
  validate-states,
)
#import "../grid/model.typ": is-node
#let wrapper(kind, ..fields) = metadata((
  mosaic: tag,
  kind: kind,
  ..fields.named(),
))

#let record-field-keys = (
  "command-on": ("after", "before", "body", "kind", "mosaic", "range"),
  "temporal-on": ("after", "before", "body", "kind", "mosaic", "range"),
  "temporal-reducer": (
    "args",
    "dim",
    "hide",
    "kind",
    "kwargs",
    "mosaic",
    "render",
  ),
  "temporal-replace": ("align", "bodies", "kind", "mosaic", "start"),
  "temporal-reveal": (
    "after",
    "before",
    "count",
    "items",
    "kind",
    "mosaic",
    "start",
  ),
)

#let temporal-kinds = (
  "temporal-on",
  "temporal-reveal",
  "temporal-replace",
  "temporal-reducer",
)

// Returns the kind of a raw incremental record, or none when the value is not
// one of the requested kinds. Records are canonical: a Mosaic-tagged record of
// a known kind must carry exactly the fields its constructor wrote.
#let record-kind(value, kinds) = {
  if (
    type(value) != dictionary
      or value.at("mosaic", default: none) != tag
      or value.at("kind", default: none) not in kinds
  ) {
    return none
  }
  if value.keys().sorted() != record-field-keys.at(value.kind) {
    fail("invalid " + value.kind + " record")
  }
  value.kind
}

#let is-command-on(value) = record-kind(value, ("command-on",)) != none

#let is-temporal(value, kind: none) = {
  if type(value) != content or value.func() != metadata {
    return false
  }
  let actual = record-kind(value.value, temporal-kinds)
  actual != none and (kind == none or actual == kind)
}

/// Shows a grid node or content only over a step range.
///
/// -> content | dictionary
#let on(
  /// Step selector such as `2`, `"2-"`, or `"2-4"`.
  /// -> int | str
  range,
  /// State before the selected range.
  /// -> str
  before: "hidden",
  /// State after the selected range.
  /// -> str
  after: "hidden",
  /// Content or grid node controlled by the range.
  /// -> content | dictionary
  body,
) = {
  _ = parse-range(range)
  validate-states(before, after)
  if is-node(body) {
    (
      mosaic: tag,
      kind: "on",
      range: range,
      before: before,
      after: after,
      child: body,
    )
  } else if type(body) == content {
    wrapper(
      "temporal-on",
      range: range,
      before: before,
      after: after,
      body: body,
    )
  } else {
    (
      mosaic: tag,
      kind: "command-on",
      range: range,
      before: before,
      after: after,
      body: body,
    )
  }
}

#let content-children(body) = if (
  type(body) == content and body.func() == typst-sequence
) {
  body.children
} else {
  (body,)
}

#let is-list-item(body) = (
  type(body) == content
    and body.func() in (list.item, enum.item, terms.item)
)

// Splits revealed items into slots. A single body holding list items reveals
// one item per step, so its untimed siblings ride along with `index: none`;
// every other shape reveals one whole entry per step. `list` reports which
// shape was found, because only the first can render as a marker grid.
#let reveal-slots(items) = {
  if items.len() == 1 and type(items.first()) == content {
    let children = content-children(items.first())
    if children.any(is-list-item) {
      let index = 0
      let slots = ()
      for child in children {
        if is-list-item(child) {
          slots.push((index: index, body: child))
          index += 1
        } else {
          slots.push((index: none, body: child))
        }
      }
      return (list: true, slots: slots)
    }
  }
  (
    list: false,
    slots: items.enumerate().map(((index, item)) => (
      index: index,
      body: item,
    )),
  )
}

#let reveal-item-count(items) = (
  reveal-slots(items).slots.filter(slot => slot.index != none).len()
)

/// Reveals content or grid nodes one step at a time.
///
/// -> content | array
#let reveal(
  /// First reveal step.
  /// -> int
  start: 1,
  /// State before each item's reveal step.
  /// -> str
  before: "hidden",
  /// State after each item's reveal step.
  /// -> str
  after: "visible",
  /// Content blocks or Mosaic grid nodes to reveal.
  /// -> arguments
  ..items,
) = {
  start = parse-positive-int(start)
  validate-states(before, after)
  let items = items.pos()
  if items.len() == 0 {
    fail("reveal expects content or at least one grid node")
  }
  let node-count = items.filter(is-node).len()
  if node-count > 0 {
    if node-count != items.len() {
      fail("reveal cannot mix content and grid nodes")
    }
    return items.enumerate().map(((index, node)) => on(
      start + index,
      before: before,
      after: after,
      node,
    ))
  }
  if not items.all(item => type(item) == content) {
    fail("reveal expects content or Mosaic grid nodes")
  }
  wrapper(
    "temporal-reveal",
    start: start,
    before: before,
    after: after,
    count: reveal-item-count(items),
    items: items,
  )
}

/// Replaces one content block with the next on successive steps.
///
/// -> content
#let replace(
  /// Step at which the first body appears.
  /// -> int
  start: 1,
  /// Alignment shared by replacement bodies.
  /// -> alignment
  align: top + left,
  /// Content blocks to replace in sequence.
  /// -> arguments
  ..bodies,
) = {
  start = parse-positive-int(start)
  let bodies = bodies.pos()
  if bodies.len() == 0 {
    fail("replace expects at least one content block")
  }
  if not bodies.all(body => type(body) == content) {
    fail(
      "replace accepts content only; replace content inside a stable "
        + "cell rather than replacing grid trees",
    )
  }
  wrapper(
    "temporal-replace",
    start: start,
    align: align,
    bodies: bodies,
  )
}

/// Defines custom rendering for visible, hidden, and dimmed incremental content.
///
/// -> content
#let reduce(
  /// Function used to render visible content.
  /// -> function
  render: none,
  /// Function used to render hidden content.
  /// -> function
  hide: none,
  /// Optional function used to render dimmed content.
  /// -> function | none
  dim: none,
  /// Named arguments forwarded to the reducer functions.
  /// -> arguments
  ..args,
) = {
  if type(render) != function {
    fail("reduce render must be a function")
  }
  if type(hide) != function {
    fail("reduce hide must be a function")
  }
  if dim != none and type(dim) != function {
    fail("reduce dim must be none or a function")
  }
  wrapper(
    "temporal-reducer",
    render: render,
    hide: hide,
    dim: dim,
    kwargs: args.named(),
    args: args.pos(),
  )
}

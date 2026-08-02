// Public incremental constructors and canonical deferred records.
#import "shared.typ": tag, fail
#import "incremental-core.typ": (
  parse-positive-int,
  parse-range,
  validate-state,
)
#import "grid-model.typ": is-node
#let wrapper(kind, ..fields) = metadata((
  mosaic: tag,
  kind: kind,
  ..fields.named(),
))

#let is-command-on(value) = (
  if (
    type(value) != dictionary
      or value.at("mosaic", default: none) != tag
      or value.at("kind", default: none) != "command-on"
  ) {
    false
  } else {
    if value.keys().sorted() != (
      "after",
      "before",
      "body",
      "kind",
      "mosaic",
      "range",
    ) {
      fail("invalid command-on record")
    }
    true
  }
)

#let temporal-field-keys = (
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
  "temporal-replace": ("align", "bodies", "count", "kind", "mosaic", "start"),
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

#let is-temporal(value, kind: none) = {
  if (
    type(value) != content
      or value.func() != metadata
      or type(value.value) != dictionary
      or value.value.at("mosaic", default: none) != tag
      or value.value.at("kind", default: none) not in temporal-field-keys
  ) {
    return false
  }
  let actual = value.value.kind
  if value.value.keys().sorted() != temporal-field-keys.at(actual) {
    fail("invalid " + actual + " record")
  }
  kind == none or actual == kind
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
  validate-state(before, "before")
  validate-state(after, "after")
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
  type(body) == content and body.func() == [].func()
) {
  body.children
} else {
  (body,)
}

#let is-list-item(body) = (
  type(body) == content
    and body.func() in (list.item, enum.item, terms.item)
)

#let reveal-item-count(items) = {
  if items.len() != 1 or type(items.first()) != content {
    return items.len()
  }
  let children = content-children(items.first())
  let count = children.filter(is-list-item).len()
  if count == 0 { 1 } else { count }
}

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
  start = parse-positive-int(start, start)
  validate-state(before, "before")
  validate-state(after, "after")
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
  start = parse-positive-int(start, start)
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
    count: bodies.len(),
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
  assert(
    type(render) == function,
    message: "mosaic: reduce render must be a function",
  )
  assert(
    type(hide) == function,
    message: "mosaic: reduce hide must be a function",
  )
  assert(
    dim == none or type(dim) == function,
    message: "mosaic: reduce dim must be none or a function",
  )
  wrapper(
    "temporal-reducer",
    render: render,
    hide: hide,
    dim: dim,
    kwargs: args.named(),
    args: args.pos(),
  )
}

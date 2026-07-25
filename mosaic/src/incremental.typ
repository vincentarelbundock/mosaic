// Public incremental constructors plus step discovery and content transformation.
#import "shared.typ": tag, fail, array-max
#import "incremental-core.typ": (
  parse-positive-int,
  parse-range,
  validate-state,
  range-last,
  status,
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

/// Defines custom rendering for visible, hidden, and dimmed temporal content.
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

#let typst-sequence = [].func()
#let typst-styled = text(red)[].func()

// Capture composable heading styles without changing the queried heading.
// The scoped show rule returns the original element unchanged.
#let capture-heading-style(style-state, it) = context {
  style-state.update((
    text: (
      font: text.font,
      fallback: text.fallback,
      style: text.style,
      weight: text.weight,
      stretch: text.stretch,
      size: text.size,
      fill: text.fill,
      stroke: text.stroke,
      tracking: text.tracking,
      spacing: text.spacing,
      baseline: text.baseline,
      lang: text.lang,
      region: text.region,
      script: text.script,
      dir: text.dir,
      hyphenate: text.hyphenate,
      kerning: text.kerning,
      features: text.features,
    ),
    block: (
      above: block.above,
      below: block.below,
      sticky: block.sticky,
    ),
    alignment: align.alignment,
  ))
  it
}

#let heading-continuation(style-state, body) = context {
  let style = style-state.get()
  if style == none {
    body
  } else {
    align(
      style.alignment,
      text(
        ..style.text,
        block(..style.block, body),
      ),
    )
  }
}

#let contains-heading(value) = {
  if type(value) == content {
    if value.func() == heading {
      return true
    }
    return value.fields().values().any(contains-heading)
  }
  if type(value) == array {
    return value.any(contains-heading)
  }
  if type(value) == dictionary {
    return value.values().any(contains-heading)
  }
  false
}

#let resolve-state(state, visible, hidden, dimmed, removed) = {
  if state == "visible" {
    visible()
  } else if state == "hidden" {
    hidden()
  } else if state == "dimmed" {
    dimmed()
  } else {
    removed()
  }
}

#let apply-state(state, body) = resolve-state(
  state,
  () => body,
  () => hide(body),
  () => text(fill: gray, body),
  () => [],
)

#let max-step(value) = {
  if is-command-on(value) {
    return calc.max(
      range-last(value.range),
      max-step(value.body),
    )
  }
  if type(value) == array {
    return array-max(value.map(max-step))
  }
  if type(value) != content {
    return 1
  }
  if is-temporal(value) {
    let timed = value.value
    if timed.kind == "temporal-reducer" {
      return max-step(timed.args)
    }
    let own = if timed.kind == "temporal-on" {
      range-last(timed.range)
    } else {
      timed.start + timed.count - 1
    }
    let nested = if timed.kind == "temporal-on" {
      max-step(timed.body)
    } else if timed.kind == "temporal-reveal" {
      max-step(timed.items)
    } else {
      max-step(timed.bodies)
    }
    return calc.max(own, nested)
  }
  if value.func() == typst-sequence {
    return max-step(value.children)
  }
  if value.func() == typst-styled {
    return max-step(value.child)
  }
  if value.func() == math.equation {
    return max-step(value.body)
  }
  1
}

#let command-array(value) = {
  if value == none {
    ()
  } else if type(value) == array {
    value
  } else {
    (value,)
  }
}

#let render-command-state(state, body, hide, dim) = {
  let rendered = resolve-state(
    state,
    () => body,
    () => hide(body),
    () => {
      if dim == none {
        fail(
          "dimmed command content requires a dim function in reduce",
        )
      }
      dim(body)
    },
    () => (),
  )
  command-array(rendered)
}

#let render-commands(values, step, hide, dim) = {
  let result = ()
  for value in command-array(values) {
    let timed = if is-command-on(value) {
      value
    } else if is-temporal(value, kind: "temporal-on") {
      value.value
    } else {
      none
    }
    if timed != none {
      let state = status(timed.range, timed.before, timed.after, step)
      let body = render-commands(timed.body, step, hide, dim)
      result += render-command-state(state, body, hide, dim)
    } else if is-temporal(value, kind: "temporal-reveal") {
      let timed = value.value
      for (index, item) in timed.items.enumerate() {
        let state = status(
          timed.start + index,
          timed.before,
          timed.after,
          step,
        )
        let body = render-commands(item, step, hide, dim)
        result += render-command-state(state, body, hide, dim)
      }
    } else if type(value) == array {
      result += render-commands(value, step, hide, dim)
    } else {
      result.push(value)
    }
  }
  result
}

#let transform(
  body,
  step,
  headings: auto,
  heading-key: "content",
) = {
  let heading-mode = if headings == auto {
    if step == 1 { "canonical" } else { "visual" }
  } else {
    headings
  }
  assert(
    heading-mode in ("canonical", "visual"),
    message: "mosaic: internal heading mode must be canonical or visual",
  )
  assert(
    type(heading-key) == str,
    message: "mosaic: internal heading key must be a string",
  )

  let visit(body) = {
    if type(body) != content {
      return body
    }
    if body.func() == heading {
      if contains-heading(body.body) {
        fail("heading bodies cannot contain nested headings")
      }
      let style-state = state(
        "mosaic:0.0.1:heading-style:"
          + heading-key
          + ":"
          + repr(body),
        none,
      )
      return if heading-mode == "canonical" {
        [
          #show heading: capture-heading-style.with(style-state)
          #body
        ]
      } else {
        heading-continuation(style-state, visit(body.body))
      }
    }
    if is-temporal(body) {
      if contains-heading(body) {
        fail(
          "headings cannot be wrapped in on, reveal, replace, or reduce; "
            + "keep semantic headings structurally stable across frames",
        )
      }
      let value = body.value
      if value.kind == "temporal-on" {
        let state = status(
          value.range,
          value.before,
          value.after,
          step,
        )
        return apply-state(state, visit(value.body))
      }
      if value.kind == "temporal-reveal" {
        let item-state(index) = status(
          value.start + index,
          value.before,
          value.after,
          step,
        )
        let render-item(index, item) = {
          apply-state(item-state(index), visit(item))
        }
        if value.items.len() == 1 {
          let reveal-body = value.items.first()
          let children = content-children(reveal-body)
          if children.any(is-list-item) {
            let list-items = children.filter(is-list-item)
            let item-kind = list-items.first().func()
            if (
              item-kind in (list.item, enum.item)
                and list-items.all(item => item.func() == item-kind)
            ) {
              let cells = ()
              for (index, item) in list-items.enumerate() {
                let state = item-state(index)
                if state != "removed" {
                  let marker = if item-kind == list.item {
                    [#sym.bullet]
                  } else {
                    [#(index + 1).]
                  }
                  cells.push(apply-state(state, marker))
                  cells.push(apply-state(state, visit(item.body)))
                }
              }
              return grid(
                columns: (1em, 1fr),
                column-gutter: 0.4em,
                row-gutter: 0.25em,
                align: (right, left),
                ..cells,
              )
            }
            let index = 0
            let result = ()
            for child in children {
              if is-list-item(child) {
                result.push(render-item(index, child))
                index += 1
              } else {
                result.push(visit(child))
              }
            }
            return result.sum(default: [])
          }
        }
        return value.items.enumerate().map(((index, item)) => (
          render-item(index, item)
        )).sum(default: [])
      }
      if value.kind == "temporal-replace" {
        return context {
          let transformed = value.bodies.map(visit)
          let sizes = transformed.map(measure)
          let width = array-max(sizes.map(size => size.width))
          let height = array-max(sizes.map(size => size.height))
          let index = calc.min(
            calc.max(step - value.start, 0),
            transformed.len() - 1,
          )
          let active = if step < value.start {
            none
          } else {
            transformed.at(index)
          }
          box(
            width: width,
            height: height,
            if active != none {
              place(value.align, active)
            },
          )
        }
      }
      if value.kind == "temporal-reducer" {
        let commands = render-commands(
          value.args,
          step,
          value.hide,
          value.dim,
        )
        return (value.render)(
          ..value.kwargs,
          commands,
        )
      }
    }
    if body.func() == typst-sequence {
      return body.children.map(visit).sum(default: [])
    }
    if body.func() == typst-styled {
      return typst-styled(visit(body.child), body.styles)
    }
    if body.func() == math.equation {
      let fields = body.fields()
      let label = fields.remove("label", default: none)
      _ = fields.remove("body")
      let equation = math.equation(
        visit(body.body),
        ..fields,
      )
      return if label == none {
        equation
      } else {
        [#equation#label]
      }
    }
    if heading-mode == "visual" and contains-heading(body) {
      let fields = body.fields()
      _ = fields.remove("label", default: none)
      let rebuilt = if body.func() in (
        block,
        box,
        pad,
        hide,
        strong,
        emph,
        smallcaps,
        sub,
        super,
        underline,
        overline,
        strike,
        highlight,
        figure,
        grid.cell,
        list.item,
        enum.item,
        quote,
        footnote,
      ) {
        let child = fields.remove("body")
        (body.func())(visit(child), ..fields)
      } else if body.func() == align {
        let alignment = fields.remove("alignment")
        let child = fields.remove("body")
        align(alignment, visit(child))
      } else if body.func() == place {
        let alignment = fields.remove("alignment")
        let child = fields.remove("body")
        place(alignment, visit(child), ..fields)
      } else if body.func() == link {
        let dest = fields.remove("dest")
        let child = fields.remove("body")
        link(dest, visit(child))
      } else if body.func() in (grid, list, enum, stack) {
        let children = fields.remove("children")
        (body.func())(..children.map(visit), ..fields)
      } else {
        fail(
          "cannot create a structurally inert continuation for a heading "
            + "nested in " + repr(body.func())
            + "; move the heading into ordinary slide flow",
        )
      }
      if contains-heading(rebuilt) {
        fail(
          "cannot create a structurally inert continuation for every "
            + "heading nested in " + repr(body.func())
            + "; move headings into ordinary slide flow",
        )
      }
      // Labels on repeated visual containers would create duplicate
      // destinations, so only the canonical first-frame container keeps them.
      return rebuilt
    }
    body
  }
  visit(body)
}

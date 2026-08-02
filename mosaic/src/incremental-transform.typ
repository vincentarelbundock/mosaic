// Incremental command reduction and content reconstruction for one step.
#import "shared.typ": fail, array-max
#import "incremental-core.typ": status
#import "incremental-command.typ": (
  content-children,
  is-command-on,
  is-list-item,
  is-temporal,
)
#import "incremental-heading.typ": (
  apply-state,
  capture-heading-style,
  contains-heading,
  heading-continuation,
  resolve-state,
  typst-sequence,
  typst-styled,
)
#import "note-command.typ": is-note

#let body-containers = (
  block, box, pad, hide, strong, emph, smallcaps, sub, super,
  underline, overline, strike, highlight, figure, grid.cell,
  list.item, enum.item, quote, footnote,
)
#let special-body-containers = (align, place, link)
#let children-containers = (grid, list, enum, stack)

#let visually-empty(value) = {
  if is-note(value) {
    return true
  }
  if type(value) != content {
    return false
  }
  if value.func() == typst-sequence {
    return value.children.all(visually-empty)
  }
  if value.func() in body-containers + special-body-containers {
    let child = value.fields().at("body", default: none)
    return child != none and visually-empty(child)
  }
  if value.func() in children-containers {
    return value.children.all(visually-empty)
  }
  false
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
    if is-note(body) {
      return []
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
              // Honor the deck's list/enum spacing when one is set.
              return context {
                let spacing = if item-kind == list.item {
                  list.spacing
                } else {
                  enum.spacing
                }
                grid(
                  columns: (1em, 1fr),
                  column-gutter: 0.4em,
                  row-gutter: if spacing == auto { 0.65em } else { spacing },
                  align: (right, left),
                  ..cells,
                )
              }
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
        ).map(visit).filter(command => not visually-empty(command))
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
    let has-visual-heading = heading-mode == "visual" and contains-heading(body)
    if body.func() in body-containers + special-body-containers + children-containers {
      let fields = body.fields()
      let label = fields.remove("label", default: none)
      let body-container = body.func() in body-containers
      if body-container and "body" not in fields {
        if has-visual-heading {
          fail(
            "cannot create a structurally inert continuation for a heading "
              + "nested in " + repr(body.func())
              + "; move the heading into ordinary slide flow",
          )
        }
        return body
      }
      let rebuilt = if body.func() in body-containers {
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
      } else if body.func() in children-containers {
        let children = fields.remove("children")
        (body.func())(..children.map(visit), ..fields)
      }
      if has-visual-heading and contains-heading(rebuilt) {
        fail(
          "cannot create a structurally inert continuation for every "
            + "heading nested in " + repr(body.func())
            + "; move headings into ordinary slide flow",
        )
      }
      // Labels on repeated visual containers would create duplicate
      // destinations. Ordinary containers retain their native labels.
      return if label == none or has-visual-heading {
        rebuilt
      } else {
        [#rebuilt#label]
      }
    }
    if has-visual-heading {
      fail(
        "cannot create a structurally inert continuation for a heading "
          + "nested in " + repr(body.func())
          + "; move the heading into ordinary slide flow",
      )
    }
    body
  }
  visit(body)
}

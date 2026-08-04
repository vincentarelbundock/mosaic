// Incremental command reduction and content reconstruction for one step.
#import "../shared.typ": fail, array-max, key, typst-sequence, typst-styled
#import "core.typ": status
#import "command.typ": (
  is-command-on,
  is-list-item,
  is-temporal,
  reveal-slots,
)
#import "heading.typ": (
  apply-state,
  capture-heading-style,
  contains-heading,
  heading-continuation,
)
#import "../note/command.typ": is-note
#import "pause.typ": has-pause, is-pause, pause-schedule
#import "analysis.typ": max-step

// Row spacing for a reconstructed list whose `list`/`enum` style leaves
// `spacing` at `auto`. Typst resolves `auto` internally and offers no way to
// read the value back, so this stands in for it; a deck that sets its own list
// spacing never reaches this.
#let default-item-spacing = 0.65em

#let body-containers = (
  block, box, pad, hide, strong, emph, smallcaps, sub, super,
  underline, overline, strike, highlight, figure, grid.cell,
  list.item, enum.item, quote, footnote, math.equation,
)
// Fields that a body container accepts only as an optional leading positional
// argument, never by name. Listed innermost-last; a container with several must
// set them all or none, since a gap would shift the remaining arguments.
#let optional-positional-fields = (
  (enum.item, ("number",)),
)
// Containers whose body follows leading positional fields.
#let special-body-containers = (
  (align, ("alignment",)),
  (place, ("alignment",)),
  (link, ("dest",)),
)
#let special-container-funcs = special-body-containers.map(entry => entry.first())
#let children-containers = (grid, list, enum, stack)
#let single-body-containers = body-containers + special-container-funcs
#let all-containers = single-body-containers + children-containers

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
  if value.func() in single-body-containers {
    let child = value.fields().at("body", default: none)
    return child != none and visually-empty(child)
  }
  if value.func() in children-containers {
    return value.children.all(visually-empty)
  }
  false
}

// Visual frames repeat a heading's appearance without repeating the element,
// which is only possible where a plain container can be rebuilt around it.
#let continuation-fail(func, plural: false) = fail(
  "cannot create a structurally inert continuation for "
    + (if plural { "every heading" } else { "a heading" })
    + " nested in " + repr(func) + "; move "
    + (if plural { "headings" } else { "the heading" })
    + " into ordinary slide flow",
)

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
  if state == "visible" {
    command-array(body)
  } else if state == "hidden" {
    command-array(hide(body))
  } else if state == "dimmed" {
    if dim == none {
      fail("dimmed command content requires a dim function in reduce")
    }
    command-array(dim(body))
  } else {
    ()
  }
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
      for slot in reveal-slots(timed.items).slots {
        let body = render-commands(slot.body, step, hide, dim)
        if slot.index == none {
          result += body
          continue
        }
        let state = status(
          timed.start + slot.index,
          timed.before,
          timed.after,
          step,
        )
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
    if is-pause(body) {
      return []
    }
    if body.func() == heading {
      if contains-heading(body.body) {
        fail("heading bodies cannot contain nested headings")
      }
      let style-state = state(
        key("heading-style:" + heading-key + ":" + repr(body)),
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
        let (list: list-mode, slots) = reveal-slots(value.items)
        let timed = slots.filter(slot => slot.index != none)
        let kinds = timed.map(slot => slot.body.func()).dedup()
        // A uniform bullet or numbered list is drawn as a marker grid so that
        // hidden items keep their markers aligned with the revealed ones.
        if list-mode and kinds.len() == 1 and kinds.first() in (
          list.item,
          enum.item,
        ) {
          let item-kind = kinds.first()
          let cells = ()
          // Explicit item numbers (`3.`) restart the count, exactly as they do
          // in a native enum; removed items still hold their number so the
          // visible markers never shift between steps.
          let number = 1
          for slot in timed {
            number = slot.body.fields().at("number", default: number)
            let state = item-state(slot.index)
            if state != "removed" {
              let marker = if item-kind == list.item {
                [#sym.bullet]
              } else {
                [#number.]
              }
              cells.push(apply-state(state, marker))
              cells.push(apply-state(state, visit(slot.body.body)))
            }
            number += 1
          }
          // A reconstructed list should measure like the native one it
          // replaces, so every metric comes from the active `list`/`enum`
          // style rather than from a guess: an `auto` marker column sizes to
          // the widest marker actually drawn, and the gutter is the element's
          // own body indent. Only the row gutter needs a fallback, because
          // `spacing: auto` means "whatever a native block would use", which
          // is not a value this grid can read back.
          return context {
            let (spacing, body-indent) = if item-kind == list.item {
              (list.spacing, list.body-indent)
            } else {
              (enum.spacing, enum.body-indent)
            }
            grid(
              columns: (auto, 1fr),
              column-gutter: body-indent,
              row-gutter: if spacing == auto {
                default-item-spacing
              } else {
                spacing
              },
              align: (right, left),
              ..cells,
            )
          }
        }
        return slots.map(slot => if slot.index == none {
          visit(slot.body)
        } else {
          apply-state(item-state(slot.index), visit(slot.body))
        }).sum(default: [])
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
      if has-pause(body.children) {
        let result = ()
        for (index, segment) in pause-schedule(
          body.children,
          max-step,
        ).enumerate() {
          let segment-body = segment.children.sum(default: [])
          let local-step = step - segment.start + 1
          let transformed = transform(
            segment-body,
            calc.max(local-step, 1),
            headings: heading-mode,
            heading-key: heading-key + ":pause-" + str(index),
          )
          result.push(
            if local-step < 1 { hide(transformed) } else { transformed },
          )
        }
        return result.sum(default: [])
      }
      return body.children.map(visit).sum(default: [])
    }
    if body.func() == typst-styled {
      return typst-styled(visit(body.child), body.styles)
    }
    let has-visual-heading = heading-mode == "visual" and contains-heading(body)
    if body.func() in all-containers {
      let fields = body.fields()
      let label = fields.remove("label", default: none)
      let body-container = body.func() in body-containers
      if body-container and "body" not in fields {
        if has-visual-heading {
          continuation-fail(body.func())
        }
        return body
      }
      let rebuilt = if body-container {
        let entry = optional-positional-fields.find(pair => (
          pair.first() == body.func()
        ))
        // Built with a loop for the same reason as `special-body-containers`.
        let positional = ()
        if entry != none {
          for name in entry.last() {
            let value = fields.remove(name, default: none)
            if value != none {
              positional.push(value)
            }
          }
        }
        (body.func())(..positional, visit(fields.remove("body")), ..fields)
      } else if body.func() in children-containers {
        let children = fields.remove("children")
        (body.func())(..children.map(visit), ..fields)
      } else {
        let names = special-body-containers.find(entry => (
          entry.first() == body.func()
        )).last()
        // Built with a loop rather than `names.map(..)`: `fields.remove` inside
        // a closure would mutate a captured variable, which Typst rejects.
        let positional = ()
        for name in names {
          positional.push(fields.remove(name))
        }
        (body.func())(..positional, visit(fields.remove("body")), ..fields)
      }
      if has-visual-heading and contains-heading(rebuilt) {
        continuation-fail(body.func(), plural: true)
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
      continuation-fail(body.func())
    }
    body
  }
  visit(body)
}

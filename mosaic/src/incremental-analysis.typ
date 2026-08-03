// Maximum-step discovery for deferred incremental content.
#import "shared.typ": array-max
#import "incremental-core.typ": range-last
#import "incremental-command.typ": is-command-on, is-temporal
#import "incremental-heading.typ": typst-sequence, typst-styled
#import "note-command.typ": is-note
#import "pause-command.typ": has-pause, is-pause, pause-schedule

#let typst-space = [ ].func()

#let max-step(value) = {
  if is-note(value) or is-pause(value) {
    return 0
  }
  if is-command-on(value) {
    let nested = max-step(value.body)
    if nested == 0 {
      return 0
    }
    return calc.max(
      range-last(value.range),
      nested,
    )
  }
  if type(value) == array {
    return array-max(value.map(max-step))
  }
  if type(value) != content {
    return 1
  }
  if value == [] or value.func() in (typst-space, parbreak) {
    return 0
  }
  if is-temporal(value) {
    let timed = value.value
    if timed.kind == "temporal-reducer" {
      return max-step(timed.args)
    }
    let nested = if timed.kind == "temporal-on" {
      max-step(timed.body)
    } else if timed.kind == "temporal-reveal" {
      max-step(timed.items)
    } else {
      max-step(timed.bodies)
    }
    if nested == 0 {
      return 0
    }
    let own = if timed.kind == "temporal-on" {
      range-last(timed.range)
    } else {
      timed.start + timed.count - 1
    }
    return calc.max(own, nested)
  }
  if value.func() == typst-sequence {
    if has-pause(value.children) {
      return pause-schedule(value.children, max-step).fold(
        0,
        (last, segment) => segment.start + segment.duration - 1,
      )
    }
    return max-step(value.children)
  }
  if value.func() == typst-styled {
    return max-step(value.child)
  }
  if value.func() == math.equation {
    return max-step(value.body)
  }
  let nested = max-step(value.fields().values())
  calc.max(1, nested)
}

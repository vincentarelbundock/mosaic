// Maximum-step discovery for deferred incremental content.
#import "../shared.typ": array-max, typst-sequence, typst-space, typst-styled
#import "core.typ": range-last
#import "command.typ": is-command-on, is-temporal
#import "../note/command.typ": is-note
#import "pause.typ": has-pause, is-pause, pause-schedule
#import "container.typ": is-container

// Does this value hold a record matching `matching`, anywhere a content walk
// can reach?
//
// Structure matters more than order here: a Mosaic temporal wrapper is itself a
// `metadata` element, so foreign metadata is rejected only after the temporal
// check, and is never walked into.
#let has-record(value, matching: none) = {
  let recurse = has-record.with(matching: matching)
  if matching(value) { return true }
  if is-command-on(value) { return recurse(value.value.body) }
  if type(value) == array { return value.any(recurse) }
  if type(value) == dictionary { return value.values().any(recurse) }
  if type(value) != content { return false }
  if value.func() == metadata {
    if is-container(value) { return recurse(value.value.parts) }
    return is-temporal(value) and recurse(value.value)
  }
  value.fields().values().any(recurse)
}

// Whether a value holds anything the slide runtime resolves per frame: a
// step, a pause, or a speaker note. Content with none of these renders the
// same wherever it is put; content with one must stay where the walks can
// reach it.
#let has-deferred-record = has-record.with(matching: value => (
  is-note(value)
    or is-pause(value)
    or is-temporal(value)
    or is-command-on(value)
))

// Elements that occupy no ink: spacing and breaks. A pause segment holding
// nothing else has nothing to reveal and must not mint a frame.
#let inert-funcs = (typst-space, parbreak, linebreak, v, h)

#let max-step(value) = {
  if is-note(value) or is-pause(value) {
    return 0
  }
  if is-command-on(value) {
    let nested = max-step(value.value.body)
    if nested == 0 {
      return 0
    }
    return calc.max(
      range-last(value.value.range),
      nested,
    )
  }
  // A container is visible in its own right, and as deep as what it holds.
  if is-container(value) {
    return calc.max(1, max-step(value.value.parts.values()))
  }
  if type(value) == array {
    return array-max(value.map(max-step))
  }
  if type(value) != content {
    return 1
  }
  if value == [] or value.func() in inert-funcs {
    return 0
  }
  if is-temporal(value) {
    let timed = value.value
    if timed.kind == "temporal-drawing" {
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
    } else if timed.kind == "temporal-reveal" {
      timed.start + timed.count - 1
    } else {
      timed.start + timed.bodies.len() - 1
    }
    return calc.max(own, nested)
  }
  if value.func() == typst-sequence {
    if has-pause(value.children) {
      let schedule = pause-schedule(value.children, max-step)
      if schedule.len() == 0 {
        return 0
      }
      let last = schedule.last()
      return last.start + last.duration - 1
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

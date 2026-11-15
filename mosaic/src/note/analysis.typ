// Speaker-note extraction for one physical incremental frame.
#import "../incremental/core.typ": status, validate-range
#import "../incremental/container.typ": is-container
#import "../incremental/command.typ": (
  is-command-on,
  is-temporal,
  replace-index,
  reveal-slots,
  slot-status,
)
#import "command.typ": is-note
#import "../grid/traversal.typ": fold-grid
#import "../incremental/pause.typ": has-pause, is-pause, pause-schedule
#import "../incremental/analysis.typ": max-step
#import "../shared.typ": typst-sequence

// Does this value hold a speaker note on any step at all?
//
// `notes-at` answers "which notes are visible on step N", which the frame loop
// needs, but running it per frame makes a deck without notes pay for a full
// content walk on every page. This predicate is the step-independent question,
// asked once per slide so the per-frame walks can be skipped entirely. It
// short-circuits and allocates nothing.
//
// Structure matters more than order here: a Mosaic temporal wrapper is itself a
// `metadata` element, so foreign metadata can only be rejected after the
// temporal check, exactly as in `notes-at` below.
#let has-note(value) = {
  if is-note(value) { return true }
  if is-command-on(value) { return has-note(value.value.body) }
  if type(value) == array { return value.any(has-note) }
  if type(value) == dictionary { return value.values().any(has-note) }
  if type(value) != content { return false }
  if value.func() == metadata {
    if is-container(value) { return has-note(value.value.parts) }
    return is-temporal(value) and has-note(value.value)
  }
  value.fields().values().any(has-note)
}

// Every note the grid's fixed cell content holds, on any step. Fixed content
// lives on the grid node rather than in the id -> content map, so a slide's
// note check has to look in both places.
#let fixed-grid-has-note(node) = fold-grid(
  node,
  cell => cell.content != none and has-note(cell.content),
  (node, child) => child,
  (node, children) => children.any(value => value),
)

// The notes visible on one step.
//
// `last` is the slide's last step. A note never adds a frame, so a note tied
// to a step the slide does not reach has no frame of its own; rather than
// being dropped it is shown on the last one. That is the meaning of `late`
// below: on the last step, a range that only begins after it is open.
#let notes-at(value, step, last: none) = {
  let late(start) = last != none and step == last and start > last
  let visit(value) = {
    if is-note(value) {
      return (value.value.body,)
    }
    if is-pause(value) {
      return ()
    }
    if is-command-on(value) or is-temporal(value, kind: "temporal-on") {
      let timed = value.value
      let state = status(timed.range, timed.before, timed.after, step)
      if state == "visible" or late(validate-range(timed.range).start) {
        return visit(timed.body)
      }
      return ()
    }
    if type(value) == array {
      return value.map(visit).sum(default: ())
    }
    if type(value) == dictionary {
      return value.values().map(visit).sum(default: ())
    }
    if type(value) != content {
      return ()
    }
    if is-container(value) {
      return visit(value.value.parts)
    }
    if is-temporal(value) {
      let timed = value.value
      if timed.kind == "temporal-reveal" {
        let result = ()
        for slot in reveal-slots(timed.items).slots {
          if (
            slot-status(timed, slot, step) == "visible"
              or (slot.index != none and late(timed.start + slot.index))
          ) {
            result += visit(slot.body)
          }
        }
        return result
      }
      if timed.kind == "temporal-replace" {
        let index = replace-index(timed, step)
        let result = if index == none { () } else {
          visit(timed.bodies.at(index))
        }
        for (position, body) in timed.bodies.enumerate() {
          if position != index and late(timed.start + position) {
            result += visit(body)
          }
        }
        return result
      }
      if timed.kind == "temporal-drawing" {
        return visit(timed.args)
      }
    }
    if value.func() == typst-sequence {
      if has-pause(value.children) {
        let result = ()
        for segment in pause-schedule(value.children, max-step) {
          let local-step = step - segment.start + 1
          if local-step > 0 {
            result += notes-at(
              segment.children,
              local-step,
              last: if last == none { none } else { last - segment.start + 1 },
            )
          }
        }
        return result
      }
    }
    if value.func() == metadata {
      return ()
    }
    value.fields().values().map(visit).sum(default: ())
  }
  visit(value)
}

#let fixed-grid-notes-at(node, step, last: none) = fold-grid(
  node,
  cell => if cell.content == none { () } else {
    notes-at(cell.content, step, last: last)
  },
  (node, child) => if (
    status(node.range, node.before, node.after, step) == "visible"
      or (
        last != none
          and step == last
          and validate-range(node.range).start > last
      )
  ) { child } else { () },
  (node, children) => children.sum(default: ()),
)

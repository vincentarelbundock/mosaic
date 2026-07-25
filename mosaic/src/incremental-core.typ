// Dependency-leaf parsing and evaluation for incremental ranges and states.
#import "shared.typ": fail

#let states = ("visible", "hidden", "dimmed", "removed")

#let validate-state(value, name) = {
  if value not in states {
    fail(
      name + " must be one of "
        + states.map(repr).join(", ")
        + ", received " + repr(value),
    )
  }
}

#let parse-positive-int(value, source) = {
  let parsed = if type(value) == int {
    value
  } else {
    if type(value) != str or value.match(regex("^\\d+$")) == none {
      fail("invalid step range " + repr(source))
    }
    int(value)
  }
  if parsed < 1 {
    fail("step numbers must be positive, received " + repr(source))
  }
  parsed
}

#let parse-range(spec) = {
  if type(spec) == int {
    let step = parse-positive-int(spec, spec)
    return (start: step, end: step)
  }
  if type(spec) != str {
    fail(
      "step range must be an integer or a string such as "
        + "\"2-\", \"-2\", or \"2-4\", received " + repr(spec),
    )
  }
  let source = spec.trim()
  if source == "" {
    fail("step range must not be empty")
  }
  let parts = source.split("-")
  if parts.len() == 1 {
    let step = parse-positive-int(parts.first(), spec)
    return (start: step, end: step)
  }
  if parts.len() != 2 or (parts.first() == "" and parts.last() == "") {
    fail("invalid step range " + repr(spec))
  }
  let start = if parts.first() == "" {
    1
  } else {
    parse-positive-int(parts.first(), spec)
  }
  let end = if parts.last() == "" {
    none
  } else {
    parse-positive-int(parts.last(), spec)
  }
  if end != none and start > end {
    fail("step range starts after it ends: " + repr(spec))
  }
  (start: start, end: end)
}

#let range-last(spec) = {
  let parsed = parse-range(spec)
  if parsed.end == none { parsed.start } else { parsed.end }
}

#let phase(spec, step) = {
  let parsed = parse-range(spec)
  if step < parsed.start {
    "before"
  } else if parsed.end != none and step > parsed.end {
    "after"
  } else {
    "active"
  }
}

#let status(spec, before, after, step) = {
  let phase = phase(spec, step)
  if phase == "before" {
    before
  } else if phase == "after" {
    after
  } else {
    "visible"
  }
}

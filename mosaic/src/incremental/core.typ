// Dependency-leaf parsing and evaluation for incremental ranges and states.
#import "../shared.typ": fail

#let states = ("visible", "hidden", "dimmed", "removed")

#let validate-state(value, name) = {
  if value not in states {
    fail(
      name + " must be one of "
        + states.map(repr).join(", ")
        + ", received " + repr(value),
    )
  }
  value
}

#let validate-states(before, after) = (
  validate-state(before, "before"),
  validate-state(after, "after"),
)

// `name` names the value quoted in diagnostics when it differs from `value`,
// as it does for one endpoint of a parsed range.
#let parse-positive-int(value, name: none) = {
  let name = if name == none { value } else { name }
  let parsed = if type(value) == int {
    value
  } else {
    if type(value) != str or value.match(regex("^\\d+$")) == none {
      fail("invalid step range " + repr(name))
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
    let step = parse-positive-int(spec)
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
    let step = parse-positive-int(parts.first(), name: spec)
    return (start: step, end: step)
  }
  if parts.len() != 2 or (parts.first() == "" and parts.last() == "") {
    fail("invalid step range " + repr(spec))
  }
  let start = if parts.first() == "" {
    1
  } else {
    parse-positive-int(parts.first(), name: spec)
  }
  let end = if parts.last() == "" {
    none
  } else {
    parse-positive-int(parts.last(), name: spec)
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

#let status(spec, before, after, step) = {
  let (start, end) = parse-range(spec)
  if step < start {
    before
  } else if end != none and step > end {
    after
  } else {
    "visible"
  }
}

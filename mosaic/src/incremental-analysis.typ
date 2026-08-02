// Maximum-step discovery for deferred incremental content.
#import "shared.typ": array-max
#import "incremental-core.typ": range-last
#import "incremental-command.typ": is-command-on, is-temporal
#import "incremental-heading.typ": typst-sequence, typst-styled

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

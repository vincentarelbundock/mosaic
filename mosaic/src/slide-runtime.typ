// Logical-slide runtime: frame policy, state, resolution, and page rendering.
#import "shared.typ": fail
#import "grid-model.typ": cell, validate, count-bodies, apply-cell-styles
#import "incremental.typ": max-step, transform
#import "render.typ": max-node, render
#import "settings.typ": settings-state, with-colors
#import "layout-resolver.typ": resolve-layout
#import "layout-core.typ": is-layout-grid
#import "layout-default.typ": progress-foreground
#import "deck-state.typ": (
  grid-state,
  background-state,
  foreground-state,
  logical-slide,
  logical-section,
  current-numbered,
  current-heading,
  slide-number,
  display-number,
)
#import "deck-commands.typ": validate-plane, validate-deck-config

#let current-step = state(
  "mosaic:0.0.1:step",
  (current: 1, total: 1),
)
#let frozen-counters-state = state("mosaic:0.0.1:frozen-counters", ())
#let frozen-states-state = state("mosaic:0.0.1:frozen-states", ())
#let handout-state = state("mosaic:0.0.1:handout", false)

#let configure-handout(value) = {
  if type(value) != bool {
    fail("setup handout must be a boolean")
  }
  handout-state.update(value)
}

#let validate-frozen(values, expected, name) = {
  if type(values) != array {
    fail(name + " must be an array")
  }
  if not values.all(value => type(value) == expected) {
    fail(name + " must contain only " + repr(expected) + " values")
  }
  values
}

#let configure-freezing(counters: (), states: ()) = {
  frozen-counters-state.update(validate-frozen(
    counters,
    counter,
    "frozen-counters",
  ))
  frozen-states-state.update(validate-frozen(
    states,
    state,
    "frozen-states",
  ))
}

#let physical-steps(total, handout) = if handout {
  (total,)
} else {
  range(1, total + 1)
}

#let prepare-frame(step, total, location, handout: false) = context {
  current-step.update((current: step, total: total))
  if not handout and step > 1 {
    for value in frozen-counters-state.get() + frozen-states-state.get() {
      value.update(value.at(selector(location)))
    }
  }
}

/// Displays the current incremental step number.
///
/// -> content
#let step-number(
  /// Whether to display the final total as `current / total`.
  /// -> bool
  total: false,
) = context {
  let value = current-step.get()
  display-number(value.current, value.total, total)
}

#let full-slide-layer(body) = place(
  top + left,
  block(width: 100%, height: 100%, body),
)

#let render-plane(value, step, heading-key) = if value == none {
  []
} else {
  transform(
    value,
    step,
    headings: "visual",
    heading-key: heading-key,
  )
}

#let configure-deck(
  default-grid: cell(id: "body"),
  background: none,
  foreground: none,
  frozen-counters: (),
  frozen-states: (),
  handout: auto,
) = {
  validate-deck-config(default-grid, background, foreground)
  grid-state.update(default-grid)
  background-state.update(background)
  foreground-state.update(foreground)
  configure-freezing(counters: frozen-counters, states: frozen-states)
  if handout != auto {
    configure-handout(handout)
  }
}
#let presentation-furniture(settings, show-logo: true) = {
  let features = settings.features
  let inset = settings.spacing.inset
  if features.section-label {
    let active = current-heading(level: 1, default: none)
    if active != none {
      place(
        top + left,
        dx: inset,
        dy: settings.spacing.compact-gap,
        text(..settings.type.small, fill: settings.colors.muted, active.body),
      )
    }
  }
  if show-logo and features.logo != none {
    place(
      top + right,
      dx: -inset,
      dy: settings.spacing.compact-gap,
      features.logo,
    )
  }
  if features.footer != none {
    place(
      bottom + left,
      dx: inset,
      dy: -settings.spacing.compact-gap,
      text(..settings.type.small, fill: settings.colors.muted, features.footer),
    )
  }
  if features.slide-number {
    place(
      bottom + right,
      dx: -inset,
      dy: -settings.spacing.compact-gap,
      text(
        ..settings.type.small,
        fill: settings.colors.muted,
        slide-number(total: features.slide-total),
      ),
    )
  }
  if features.progress {
    place(
      bottom + left,
      block(width: 100%, height: 3pt)[
        #rect(width: 100%, height: 3pt, fill: settings.colors.line)
        #place(left, context {
          let current = logical-slide.get().first()
          let final = logical-slide.final().first()
          rect(
            width: if final == 0 { 0% } else { 100% * current / final },
            height: 3pt,
            fill: settings.colors.accent,
          )
        })
      ],
    )
  }
}

#let render-slide-with-settings(command, settings) = context {
  let requested-grid = command.grid
  let is-section-layout = (
    is-layout-grid(requested-grid)
      and requested-grid.name == "section"
  )
  let suppress-global-logo = if is-layout-grid(requested-grid) {
    requested-grid.suppress-global-logo
  } else {
    false
  }
  let resolved-grid = if requested-grid == auto {
    grid-state.get()
  } else if is-layout-grid(requested-grid) {
    resolve-layout(requested-grid, settings)
  } else {
    requested-grid
  }
  validate(resolved-grid)
  let resolved-grid = apply-cell-styles(resolved-grid, command.cell-styles)
  validate(resolved-grid)
  let resolved-background = if command.background == auto {
    background-state.get()
  } else {
    command.background
  }
  let resolved-foreground = if command.foreground == auto {
    foreground-state.get()
  } else {
    command.foreground
  }
  let layout-foreground = if (
    is-layout-grid(requested-grid)
      and requested-grid.name == "default"
  ) {
    progress-foreground(requested-grid, settings)
  } else {
    none
  }
  let resolved-foreground = if layout-foreground == none {
    resolved-foreground
  } else if resolved-foreground == none {
    layout-foreground
  } else {
    [#resolved-foreground #layout-foreground]
  }
  validate-plane(resolved-background, "background")
  validate-plane(resolved-foreground, "foreground")
  let expected = count-bodies(resolved-grid)
  assert(
    command.bodies.len() == expected,
    message: "mosaic: grid expects " + str(expected)
      + " bodies, received " + str(command.bodies.len()),
  )
  let steps = calc.max(
    max-node(resolved-grid),
    max-step(command.bodies),
    max-step(resolved-background),
    max-step(resolved-foreground),
  )
  current-numbered.update(command.numbered)
  if command.numbered {
    logical-slide.step()
  }
  if command.section or is-section-layout {
    logical-section.step()
  }
  let slide = logical-slide.get().first()
  let freeze-location = here()
  let handout = handout-state.get()
  for step in physical-steps(steps, handout) {
    let result = render(
      resolved-grid,
      command.bodies,
      step,
      overflow: settings.features.overflow,
      slide: slide,
    )
    assert(result.at(1) == expected)
    pagebreak(weak: true)
    prepare-frame(step, steps, freeze-location, handout: handout)
    let background-content = render-plane(resolved-background, step, "background")
    let foreground-content = render-plane(resolved-foreground, step, "foreground")
    block(
      width: 100%,
      height: 100%,
      above: 0pt,
      below: 0pt,
      breakable: false,
      [
        #full-slide-layer(background-content)
        #full-slide-layer(result.at(0))
        #full-slide-layer(foreground-content)
        #full-slide-layer(presentation-furniture(
          settings,
          show-logo: not suppress-global-logo,
        ))
      ],
    )
  }
}

#let render-slide(command) = context {
  let settings = settings-state.get()
  if command.colors == auto {
    render-slide-with-settings(command, settings)
  } else {
    settings = with-colors(settings, command.colors)
    set page(fill: settings.colors.canvas)
    set text(fill: settings.colors.text)
    render-slide-with-settings(command, settings)
  }
}

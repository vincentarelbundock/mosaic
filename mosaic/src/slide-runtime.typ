// Logical-slide runtime: frame policy, state, resolution, and page rendering.
#import "shared.typ": fail
#import "grid-model.typ": cell, validate, resolve-content
#import "incremental-analysis.typ": max-step
#import "incremental-transform.typ": transform
#import "render.typ": max-node, render
#import "settings.typ": settings-state
#import "color-defaults.typ": default-muted, default-line, default-accent
#import "layout-resolver.typ": resolve-layout
#import "layout-core.typ": is-layout-grid
#import "layout-default.typ": progress-foreground
#import "components.typ": progress as progress-component
#import "deck-state.typ": (
  grid-state,
  background-state,
  foreground-state,
  logical-slide,
  logical-section,
  current-numbered,
  slide-number,
)
#import "slide-command.typ": validate-plane, validate-deck-config

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

#let prepare-frame(step, location, handout: false) = context {
  if not handout and step > 1 {
    for value in frozen-counters-state.get() + frozen-states-state.get() {
      value.update(value.at(selector(location)))
    }
  }
}


#let full-slide-layer(body) = place(
  top + left,
  block(width: 100%, height: 100%, body),
)

// A plane renders as one full-slide block labeled <mosaic-cell-ID> (ID is
// "background" or "foreground"), so the same native label rules that style
// cells also style planes.
#let render-plane(value, step, heading-key) = if value == none {
  []
} else {
  let body = block(
    width: 100%,
    height: 100%,
    transform(
      value,
      step,
      headings: "visual",
      heading-key: heading-key,
    ),
  )
  [#body#label("mosaic-cell-" + heading-key)]
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
      text(..settings.type.small, fill: default-muted, features.footer),
    )
  }
  if features.slide-number {
    place(
      bottom + right,
      dx: -inset,
      dy: -settings.spacing.compact-gap,
      text(
        ..settings.type.small,
        fill: default-muted,
        slide-number(total: features.slide-total),
      ),
    )
  }
  if features.progress {
    place(
      bottom + left,
      progress-component(
        variant: "line",
        width: 100%,
        thickness: 3pt,
        track: default-line,
        color: default-accent,
      ),
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
  // The reserved plane ids live in the same content map as the cells. Absent
  // means inherit the deck plane, content overrides it for this slide, and
  // none omits it.
  let content-map = command.content
  let background-override = content-map.remove("background", default: auto)
  let foreground-override = content-map.remove("foreground", default: auto)
  let resolved-background = if background-override == auto {
    background-state.get()
  } else {
    background-override
  }
  let resolved-foreground = if foreground-override == auto {
    foreground-state.get()
  } else {
    foreground-override
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
  // Named and positional content collapse to one id -> content map before
  // rendering, so the renderer, overflow, and incremental paths look content up
  // by cell id with no positional cursor.
  let contents = resolve-content(resolved-grid, content-map, command.bodies)
  let steps = calc.max(
    max-node(resolved-grid),
    max-step(contents.values()),
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
    let rendered = render(
      resolved-grid,
      contents,
      step,
      overflow: settings.features.overflow,
      slide: slide,
    )
    pagebreak(weak: true)
    prepare-frame(step, freeze-location, handout: handout)
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
        #full-slide-layer(rendered)
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
  render-slide-with-settings(command, settings)
}

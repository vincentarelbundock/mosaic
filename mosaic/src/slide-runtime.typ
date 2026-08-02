// Logical-slide runtime: frame policy, state, resolution, and page rendering.
#import "shared.typ": fail, tag
#import "grid-model.typ": cell, validate, resolve-content
#import "incremental-analysis.typ": max-step
#import "incremental-transform.typ": transform
#import "note-analysis.typ": notes-at, fixed-grid-notes-at
#import "note-command.typ": is-note
#import "render.typ": max-node, render
#import "settings.typ": settings-state
#import "color-defaults.typ": default-canvas, default-muted, default-line, default-accent
#import "layout-resolver.typ": resolve-layout
#import "layout-core.typ": is-layout-grid
#import "layout-default.typ": progress-foreground
#import "components.typ": progress as progress-component
#import "deck-state.typ": (
  grid-state,
  background-state,
  foreground-state,
  logical-slide,
  logical-slide-id,
  logical-section,
  current-numbered,
  slide-number,
)
#import "slide-command.typ": validate-plane, validate-deck-config

#let frozen-counters-state = state("mosaic:0.0.1:frozen-counters", ())
#let frozen-states-state = state("mosaic:0.0.1:frozen-states", ())
#let handout-state = state("mosaic:0.0.1:handout", false)
#let output-state = state("mosaic:0.0.1:output", "slides")
#let paper-state = state("mosaic:0.0.1:paper", "16-9")

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

#let source-slide-size(paper) = if paper == "4-3" {
  (width: 10in, height: 7.5in)
} else {
  (width: 13.333333in, height: 7.5in)
}

#let slide-frame(
  body,
  width: 100%,
  height: 100%,
  fill: none,
  stroke: none,
) = block(
  width: width,
  height: height,
  fill: fill,
  stroke: stroke,
  above: 0pt,
  below: 0pt,
  breakable: false,
  body,
)

#let note-list(notes) = {
  set text(size: 10pt, fill: black)
  if notes.len() == 0 {
    emph[No speaker notes for this frame.]
  } else {
    let result = []
    for note in notes {
      result += block(above: 0pt, below: 3mm, note)
    }
    result
  }
}

#let note-heading(slide, step, steps) = text(
  size: 12pt,
  weight: "bold",
  fill: black,
)[Slide #slide · Frame #step of #steps]

#let bounded-note-list(notes, width, height, output, step) = {
  let body = note-list(notes)
  let natural = measure(body, width: width)
  if natural.height > height {
    fail(output + " output notes overflow on frame " + str(step))
  }
  block(
    width: width,
    breakable: false,
    above: 0pt,
    below: 0pt,
    body,
  )
}

#let speaker-page(frame, notes, slide, step, steps, paper, fill) = layout(region => {
  let source-size = source-slide-size(paper)
  let source = slide-frame(
    frame,
    width: source-size.width,
    height: source-size.height,
    fill: fill,
    stroke: 0.6pt + default-line,
  )
  let factor = region.width / source-size.width * 100%
  let thumbnail-height = source-size.height * (region.width / source-size.width)
  let heading = note-heading(slide, step, steps)
  let heading-height = measure(heading, width: region.width).height
  let notes-height = region.height - thumbnail-height - 13mm - heading-height
  [
    #scale(
      x: factor,
      y: factor,
      reflow: true,
      origin: top + left,
      source,
    )
    #v(7mm)
    #heading
    #v(4mm)
    #bounded-note-list(
      notes,
      region.width,
      notes-height,
      "speaker",
      step,
    )
  ]
})

#let notes-page(frame, notes, slide, step, steps, paper, fill) = layout(region => {
  // Lay out the semantic slide invisibly so native counters and state updates
  // retain the same frame semantics as the slide and speaker outputs.
  let source-size = source-slide-size(paper)
  place(hide(slide-frame(
    frame,
    width: source-size.width,
    height: source-size.height,
    fill: fill,
  )))
  let heading = note-heading(slide, step, steps)
  let heading-height = measure(heading, width: region.width).height
  heading
  v(4mm)
  bounded-note-list(
    notes,
    region.width,
    region.height - heading-height - 6mm,
    "notes",
    step,
  )
})

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
  output: "slides",
  paper: "16-9",
) = {
  validate-deck-config(default-grid, background, foreground)
  grid-state.update(default-grid)
  background-state.update(background)
  foreground-state.update(foreground)
  configure-freezing(counters: frozen-counters, states: frozen-states)
  if handout != auto {
    configure-handout(handout)
  }
  if output not in ("slides", "speaker", "notes") {
    fail("setup output must be \"slides\", \"speaker\", or \"notes\"")
  }
  if paper not in ("16-9", "4-3") {
    fail("setup paper must be \"16-9\" or \"4-3\"")
  }
  output-state.update(output)
  paper-state.update(paper)
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
  logical-slide-id.step()
  if command.numbered {
    logical-slide.step()
  }
  if command.section or is-section-layout {
    logical-section.step()
  }
  let slide = logical-slide-id.get().first()
  let freeze-location = here()
  let handout = handout-state.get()
  let output = output-state.get()
  let paper = paper-state.get()
  let slide-fill = if page.fill == auto { default-canvas } else { page.fill }
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
    let notes = (
      fixed-grid-notes-at(resolved-grid, step)
        + notes-at(contents.values(), step)
        + notes-at(resolved-background, step)
        + notes-at(resolved-foreground, step)
    )
    let frame = [
        #show metadata: it => if is-note(it) { [] } else { it }
        #full-slide-layer(background-content)
        #full-slide-layer(rendered)
        #full-slide-layer(foreground-content)
        #full-slide-layer(presentation-furniture(
          settings,
          show-logo: not suppress-global-logo,
        ))
    ]
    place(hide([
      #metadata((
        mosaic: tag,
        kind: "speaker-notes",
        logical-slide: slide,
        frame: step,
        notes: notes,
      )) <mosaic-speaker-notes>
    ]))
    if output == "slides" {
      slide-frame(frame)
    } else if output == "speaker" {
      speaker-page(frame, notes, slide, step, steps, paper, slide-fill)
    } else {
      notes-page(frame, notes, slide, step, steps, paper, slide-fill)
    }
  }
}

#let render-slide(command) = context {
  let settings = settings-state.get()
  render-slide-with-settings(command, settings)
}

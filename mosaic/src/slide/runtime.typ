// Logical-slide runtime: frame policy, state, resolution, and page rendering.
#import "../shared.typ": fail, tag
#import "../grid/validation.typ": validate
#import "../grid/content.typ": resolve-content
#import "../incremental/analysis.typ": max-step
#import "../incremental/transform.typ": transform
#import "../note/analysis.typ": notes-at, fixed-grid-notes-at
#import "../note/command.typ": is-note
#import "../grid/render.typ": max-node, render
#import "../settings.typ": settings-state
#import "../color-defaults.typ": default-line
#import "../layout/resolver.typ": resolve-layout
#import "../layout/core.typ": is-layout
#import "../layout/config.typ": unconfigured-layouts, validate-layouts
#import "../deck-state.typ": (
  layouts-state,
  logical-slide,
  logical-slide-id,
  logical-section,
)
#import "command.typ": validate-plane

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

// A plane renders as one full-slide block labeled <mosaic-ID> (ID is
// "background" or "foreground"), so native label rules can style it without
// conflating planes with grid cells.
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
  [#body#label("mosaic-" + heading-key)]
}

#let configure-deck(
  layouts: (:),
  frozen-counters: (),
  frozen-states: (),
  handout: auto,
  output: "slides",
  paper: "16-9",
) = {
  layouts-state.update(validate-layouts(layouts))
  configure-freezing(counters: frozen-counters, states: frozen-states)
  if handout != auto {
    configure-handout(handout)
  }
  // `output` and `paper` are validated by `setup`, the only caller.
  output-state.update(output)
  paper-state.update(paper)
}

#let select-layout(value, configured) = if value == auto {
  ("content", configured.content)
} else if type(value) == str {
  // Configurable names come from setup; the rest are selectable-only stubs
  // that the slide's own named fields refine.
  (value, configured.at(value, default: unconfigured-layouts.at(value, default: none)))
} else if is-layout(value) {
  (value.name, value)
} else {
  ("content", value)
}

#let render-slide-with-settings(command, settings) = context {
  let (layout-name, requested-layout) = select-layout(
    command.layout,
    layouts-state.get(),
  )
  // Field overlay (see `slide-command`): the slide's named arguments and the
  // deck compiler's automatic section tagline. It refines the configured
  // layout rather than replacing it, so a theme's variant, accent, and image
  // survive. Each layout's resolver re-validates the merged field set, so an
  // overlay cannot smuggle an unsupported combination past construction.
  let overlay = command.at("fields", default: (:))
  if overlay.len() > 0 {
    if not is-layout(requested-layout) {
      fail(
        "the configured " + layout-name + " layout is a raw grid, which "
          + "cannot carry layout fields; supply them on an explicit "
          + "slide layout instead",
      )
    }
    requested-layout = requested-layout + (
      fields: requested-layout.fields + overlay,
    )
  }
  let resolved-grid = if is-layout(requested-layout) {
    resolve-layout(requested-layout, settings)
  } else {
    requested-layout
  }
  validate(resolved-grid)
  // The reserved plane ids live in the same content map as the cells. Absent
  // means inherit the deck plane, content overrides it for this slide, and
  // none omits it.
  let content-map = command.content
  let background-override = content-map.remove("background", default: auto)
  let foreground-override = content-map.remove("foreground", default: auto)
  let resolved-background = if background-override == auto {
    settings.content.at("background", default: none)
  } else {
    background-override
  }
  let resolved-foreground = if foreground-override == auto {
    settings.content.at("foreground", default: none)
  } else {
    foreground-override
  }
  validate-plane(resolved-background, "background")
  validate-plane(resolved-foreground, "foreground")
  // Named and positional content collapse to one id -> content map before
  // rendering, so the renderer, overflow, and incremental paths look content up
  // by cell id with no positional cursor.
  let contents = resolve-content(
    resolved-grid,
    content-map,
    command.bodies,
    defaults: settings.content,
  )
  let steps = calc.max(
    max-node(resolved-grid),
    max-step(contents.values()),
    max-step(resolved-background),
    max-step(resolved-foreground),
  )
  logical-slide-id.step()
  let numbered = if command.numbered == auto {
    layout-name == "content"
  } else {
    command.numbered
  }
  if numbered {
    logical-slide.step()
  }
  if layout-name == "section" {
    logical-section.step()
  }
  let slide = logical-slide-id.get().first()
  let freeze-location = here()
  let handout = handout-state.get()
  let output = output-state.get()
  let paper = paper-state.get()
  let slide-fill = if page.fill == auto { settings.colors.canvas } else { page.fill }
  for step in physical-steps(steps, handout) {
    let rendered = render(
      resolved-grid,
      contents,
      step,
      overflow: settings.overflow,
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

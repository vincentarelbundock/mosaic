// Logical-slide runtime: frame policy, state, resolution, and page rendering.
#import "../shared.typ": fail, key, tag
#import "../paper.typ": default-paper, paper-aliases
#import "../grid/validation.typ": validate
#import "../grid/content.typ": resolve-content
#import "../incremental/analysis.typ": max-step
#import "../incremental/transform.typ": transform
#import "../incremental/heading.typ": strip-headings
#import "../note/analysis.typ": notes-at, fixed-grid-notes-at
#import "../note/command.typ": is-note
#import "../grid/render.typ": max-node, render
#import "../fit.typ": fit-ratio
#import "../settings.typ": settings-state
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

#let frozen-counters-state = state(key("frozen-counters"), ())
#let frozen-states-state = state(key("frozen-states"), ())
#let handout-state = state(key("handout"), false)
#let output-state = state(key("output"), "slides")
// The slide size as resolved dimensions, never as a preset name: the printed
// outputs scale a thumbnail of this size onto a page of a different one.
#let paper-state = state(key("paper"), paper-aliases.at(default-paper))

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

#let note-list(notes, style) = {
  set text(size: style.text-size, fill: style.text-fill)
  if notes.len() == 0 {
    emph[No speaker notes for this frame.]
  } else {
    let result = []
    for note in notes {
      result += block(above: 0pt, below: style.note-gap, note)
    }
    result
  }
}

#let note-heading(slide, step, steps, style) = text(
  size: style.heading-size,
  weight: style.heading-weight,
  fill: style.heading-fill,
)[Slide #slide · Frame #step of #steps]

#let bounded-note-list(notes, width, height, output, step, style) = {
  let body = note-list(notes, style)
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

#let speaker-page(frame, notes, slide, step, steps, source-size, fill, style) = layout(region => {
  let source = slide-frame(
    frame,
    width: source-size.width,
    height: source-size.height,
    fill: fill,
    stroke: style.thumbnail-stroke,
  )
  // The thumbnail is a whole slide scaled into the notes column, which is the
  // same width problem the fitters solve, so the factor comes from their shared
  // geometry rather than from a second copy of the arithmetic here.
  let factor = fit-ratio(source-size, width: region.width)
  let thumbnail-height = source-size.height * factor
  let heading = note-heading(slide, step, steps, style)
  let heading-height = measure(heading, width: region.width).height
  // The vertical budget, stated as the sum of what the page actually places
  // rather than as one combined allowance.
  let notes-height = (
    region.height
      - thumbnail-height
      - style.thumbnail-gap
      - heading-height
      - style.heading-gap
      - style.padding
  )
  [
    #scale(
      x: factor,
      y: factor,
      reflow: true,
      origin: top + left,
      source,
    )
    #v(style.thumbnail-gap)
    #heading
    #v(style.heading-gap)
    #bounded-note-list(
      notes,
      region.width,
      notes-height,
      "speaker",
      step,
      style,
    )
  ]
})

#let notes-page(frame, notes, slide, step, steps, source-size, fill, style) = layout(region => {
  // Lay out the semantic slide invisibly so native counters and state updates
  // retain the same frame semantics as the slide and speaker outputs.
  place(hide(slide-frame(
    frame,
    width: source-size.width,
    height: source-size.height,
    fill: fill,
  )))
  let heading = note-heading(slide, step, steps, style)
  let heading-height = measure(heading, width: region.width).height
  heading
  v(style.heading-gap)
  bounded-note-list(
    notes,
    region.width,
    region.height - heading-height - style.heading-gap - style.padding,
    "notes",
    step,
    style,
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
  paper: paper-aliases.at(default-paper),
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
    // One queryable record per section slide, emitted right after the step so
    // `logical-section.at(location)` gives this slide's section number. The
    // stored title is heading-stripped: consumers (the toc section variant)
    // re-render it without minting duplicate outline entries.
    [#metadata((
      mosaic: tag,
      kind: "section-title",
      title: strip-headings(contents.at("section", default: none)),
    )) <mosaic-section-title>]
  }
  let slide = logical-slide-id.get().first()
  let freeze-location = here()
  let handout = handout-state.get()
  let output = output-state.get()
  let paper = paper-state.get()
  let slide-fill = if page.fill == auto { settings.colors.canvas } else { page.fill }
  for step in physical-steps(steps, handout) {
    // The whole cell grid carries <mosaic-slide>, so one native rule can reach
    // every cell of a slide at once:
    //
    //   show label("mosaic-slide"): set text(fill: white)
    //
    // Without it, styling a slide means naming each cell the resolved layout
    // happens to produce, and a change of variant silently leaves a cell
    // behind. Per-cell labels still apply, and sit inside this one, so a
    // <mosaic-cell-*> rule refines what this sets.
    let rendered = [
      #render(
        resolved-grid,
        contents,
        step,
        overflow: settings.overflow,
        slide: slide,
      )
      #label("mosaic-slide")
    ]
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
      speaker-page(
        frame, notes, slide, step, steps, paper, slide-fill, settings.notes,
      )
    } else {
      notes-page(
        frame, notes, slide, step, steps, paper, slide-fill, settings.notes,
      )
    }
  }
}

// The deck's resolved body text size, read here rather than stored at setup.
// Themes own every `set text` rule, so the engine cannot know the size in
// advance; this context sits inside the theme's rules but outside the labeled
// cells, so it observes the body size the deck actually renders at, before any
// <mosaic-cell-*> display scale applies. Layouts anchor their composed tiers to
// it, which is what keeps a title's subtitle proportional to its own theme.
#let render-slide(command) = context {
  let settings = settings-state.get()
  if settings != none {
    settings.insert("base-size", text.size)
  }
  render-slide-with-settings(command, settings)
}

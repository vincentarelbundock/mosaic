// Compilation of top-level Typst content into explicit and automatic slides.
#import "shared.typ": fail, typst-sequence, typst-space, typst-styled
#import "slide/command.typ": is-slide-command, slide-command
#import "slide/runtime.typ": render-slide
#import "incremental/heading.typ": resolve-heading-depth

#let typst-context = (context []).func()

// Which heading depths open an automatic slide, and what each one opens.
//
// The default reads a deck the way its outline does: `=` starts a section,
// `==` starts a content slide, and anything deeper is ordinary content inside
// the current slide. A document with a different hierarchy (chapters at `=`,
// sections at `==`, slides at `===`) passes its own map instead, so the
// compiler is not the thing that decides what a heading level means.
// Keyed by the depth written as a string, because Typst dictionary keys are
// strings; `heading-role` below does the conversion in one place.
#let default-heading-policy = ("1": "section", "2": "slide")

#let validate-heading-policy(value) = {
  let name = "setup headings"
  if type(value) != dictionary {
    fail(
      name + " must be a dictionary mapping heading level to \"section\" or "
        + "\"slide\"",
    )
  }
  for (level, role) in value {
    // Checked as a canonical decimal spelling rather than through `int()`: a
    // non-numeric key would abort with a raw conversion error, and a
    // zero-padded key would never match the `str(level)` lookup in
    // `heading-role` below.
    if level.match(regex("^[1-9][0-9]*$")) == none {
      fail(
        name + " levels must be positive integers written without leading "
          + "zeros",
      )
    }
    if role not in ("section", "slide") {
      fail(name + " " + repr(level) + " must be \"section\" or \"slide\"")
    }
  }
  value
}

#let heading-role(policy, level) = if level == none {
  none
} else {
  policy.at(str(level), default: none)
}
#let is-heading-space(value) = (
  value == []
    or (
      type(value) == content
        and value.func() in (parbreak, typst-space)
    )
)

#let wrap-content(value, wrappers) = {
  for wrapper in wrappers.rev() {
    value = (wrapper.func)(value, wrapper.styles)
  }
  value
}

#let top-level-content(body, wrappers: (), path: ()) = if (
  type(body) == content and body.func() == typst-sequence
) {
  body.children.enumerate().map(((index, child)) => top-level-content(
    child,
    wrappers: wrappers,
    path: path + (index,),
  )).flatten()
} else if type(body) == content and body.func() == typst-styled {
  top-level-content(
    body.child,
    wrappers: wrappers + ((
      func: body.func(),
      styles: body.styles,
      // The tree position of the styled element this wrapper came from, so
      // two entries share a wrapper prefix only when they sit inside the very
      // same styled elements, not merely equally many.
      id: path,
    ),),
    path: path + (0,),
  )
} else {
  ((
    raw: body,
    shown: wrap-content(body, wrappers),
    wrappers: wrappers,
  ),)
}

#let wrapper-ids(wrappers) = wrappers.map(wrapper => wrapper.id)

// How many leading styled elements two wrapper stacks share.
#let shared-wrapper-count(first, second) = {
  let first = wrapper-ids(first)
  let second = wrapper-ids(second)
  let count = 0
  while (
    count < calc.min(first.len(), second.len())
      and first.at(count) == second.at(count)
  ) {
    count += 1
  }
  count
}

// A slide is one unbreakable full-page block, so the page has no room left
// for a footnote's entry: Typst would move the entry to a page of its own,
// and the deck would gain a blank slide carrying one stray line.
#let render-deck-slide(command) = {
  show footnote: _ => fail(
    "footnotes are not supported on slides, where the entry would spill "
      + "onto an extra page; put the note in a footer cell instead",
  )
  render-slide(command)
}

#let is-deck-marker(value) = (
  type(value) == content
    and value.func() == metadata
    and value.at("label", default: none) == label("mosaic-deck-metadata")
)

// Whether a slide command sits somewhere inside this content. The compiler
// only recognizes a slide at the top level of the deck, so one wrapped in a
// block, a box, or any other container would otherwise be reported as stray
// content, which names the wrong problem.
#let has-slide-command(value) = {
  if type(value) == array {
    return value.any(has-slide-command)
  }
  if type(value) != content {
    return false
  }
  if value.func() == metadata {
    return is-slide-command(value)
  }
  value.fields().values().any(has-slide-command)
}

// Names the levels the deck actually compiles on, which the heading policy
// may have moved. Ordered as numbers without converting them, so a level too
// large for an integer cannot abort the diagnostic that reports it.
#let stray-content-error(headings) = if headings.len() == 0 {
  (
    "content appears outside a slide; setup headings maps no heading level, "
      + "so every slide must be an explicit slide command"
  )
} else {
  (
    "content appears before the first heading handled by setup; expected "
      + "one of heading levels "
      + headings.keys().sorted(key: level => (level.len(), level)).join(", ")
  )
}
// Automatic and explicit pages use the same layout-based slide command.
#let compile-deck(body, headings: default-heading-policy) = {
  let output = ()
  let mode = none
  let section = none
  let current = ()
  let flushed = none
  let slide-wrappers = ()

  // Automatic slides re-apply the user's captured set/show wrappers around
  // the rendered slide, exactly as explicit slide commands do, so deck-level
  // rules (including label-targeted cell rules) see the rendered cell
  // structure.
  let flush(mode, section, current, wrappers) = {
    if mode == "slide" {
      let body = current.sum(default: [])
      wrap-content(
        render-deck-slide(slide-command(
          (),
          layout: "content",
          automatic: true,
          cells: (header: section, body: body),
        )),
        wrappers,
      )
    } else if mode == "section" {
      // Content between `=` and the next `==` is the section's tagline. It
      // reaches the configured section layout as its `subtitle` field, so an
      // automatic section slide looks exactly like the explicit
      // `m.layouts.section(subtitle: ...)` form and the heading keeps its
      // outline entry.
      let tagline = current.sum(default: none)
      wrap-content(
        render-deck-slide(slide-command(
          (),
          layout: "section",
          automatic: true,
          cells: (section: section),
          fields: if tagline == none { (:) } else { (subtitle: tagline) },
        )),
        wrappers,
      )
    } else {
      none
    }
  }

  let flush-current(mode, section, current, wrappers) = (
    flush(mode, section, current, wrappers),
    none,
    none,
    (),
  )

  for entry in top-level-content(body) {
    let value = entry.raw
    let shown = entry.shown
    // Content collected into an automatic slide is re-styled by
    // the outer wrap in flush(); strip the slide-level wrapper prefix from
    // each piece so those styles are not applied twice (relative units such
    // as em sizes would compound). Only a genuine prefix is stripped — the
    // piece must sit inside the very styled elements that wrap the heading —
    // so a separately styled sibling keeps its own styles through `shown`.
    //
    // A piece that sits outside some of those elements narrows the slide's
    // wrappers to the ones both share: the styles it escaped move inward,
    // onto the heading and the pieces collected so far, instead of reaching
    // around the whole slide and restyling content their author left
    // outside them. Spacing never narrows; it carries no style to protect.
    let shared = shared-wrapper-count(entry.wrappers, slide-wrappers)
    if (
      mode != none
        and shared < slide-wrappers.len()
        and not is-heading-space(value)
        and not is-slide-command(value)
    ) {
      let escaped = slide-wrappers.slice(shared)
      section = wrap-content(section, escaped)
      current = current.map(piece => wrap-content(piece, escaped))
      slide-wrappers = slide-wrappers.slice(0, shared)
    }
    let inner = wrap-content(value, entry.wrappers.slice(shared))
    let level = if (
      type(value) == content and value.func() == heading
    ) {
      // Markup headings carry `depth`; a heading constructed with
      // `heading(level: ..)` carries `level` instead, and reading the absent
      // field would abort with a raw Typst error. Anything non-numeric (an
      // explicit `level: auto`) falls back to the native default depth of 1.
      let fields = value.fields()
      let depth = fields.at("depth", default: fields.at("level", default: 1))
      if type(depth) == int { depth } else { 1 }
    } else {
      none
    }
    let role = heading-role(headings, level)

    if is-deck-marker(value) {
      // A second `setup` wraps the first one's whole output, so the nested
      // deck arrives here as body content before its state write can report
      // itself. Its metadata record is the first thing it emits.
      fail("setup already configured this deck; apply setup exactly once")
    } else if is-slide-command(value) {
      (flushed, mode, section, current) = flush-current(mode, section, current, slide-wrappers)
      if flushed != none { output.push(flushed) }
      output.push(wrap-content(
        render-deck-slide(value.value),
        entry.wrappers,
      ))
    } else if role != none {
      (flushed, mode, section, current) = flush-current(mode, section, current, slide-wrappers)
      if flushed != none { output.push(flushed) }
      mode = role
      section = resolve-heading-depth(value)
      current = ()
      slide-wrappers = entry.wrappers
    } else if is-heading-space(value) {
      // In section mode, spacing separates tagline paragraphs but must not
      // open the tagline with an empty block.
      if mode == "slide" or (mode == "section" and current.len() > 0) {
        current.push(inner)
      }
    } else if (
      mode == none
        and type(value) == content
        and value.func() in (metadata, typst-context)
    ) {
      output.push(shown)
    } else if mode in ("slide", "section") {
      current.push(inner)
    } else {
      if has-slide-command(value) {
        fail("slide cannot be nested inside another slide or a container")
      }
      fail(stray-content-error(headings))
    }
  }

  let flushed = flush(mode, section, current, slide-wrappers)
  if flushed != none { output.push(flushed) }
  output.sum(default: [])
}

// Heading inspection, canonical style capture, and inert continuations.
#import "../shared.typ": fail, key
#import "../note/command.typ": is-note
// Re-exported for `grid/render.typ`, which still imports it from here.
#import "core.typ": apply-state

// The physical step that carries a slide's real headings and reference
// labels. The slide runtime sets it before the frames of each slide: step 1
// when every step is rendered, the last step in handout mode, where it is the
// only one. `transform` knows the answer statically when it is step 1 and asks
// this state otherwise.
#let canonical-frame = state(key("canonical-frame"), 1)

// Emits `labeled` on the canonical frame and `plain` on every other one, so a
// reference label exists exactly once per logical slide.
#let canonical-only(labeled, plain, frame) = context {
  if canonical-frame.get() == frame { labeled } else { plain }
}

// The decorations wrapped around the heading being realized, outermost first.
// `capture-heading-style` is the last rule declared and therefore the first
// applied, so its output encloses everything the other rules build. It clears
// this list, each `decorate-heading` rule that then fires on the heading adds
// its function, and a reader placed after the heading files the result with
// that heading's captured style. A continuation frame has no heading element
// for a show rule to match, so this is how the rules that matched the real one
// are found again.
#let pending-decorations = state(key("pending-heading-decorations"), ())

/// Decorates headings with a transforming show rule that survives on every
/// frame of an incremental slide.
///
/// A slide's heading is a real `heading` element on one frame only; the other
/// frames repeat its appearance without the element, so the outline, the
/// bookmarks, and `query(heading)` see one heading per logical slide. Set
/// rules (`show heading: set text(..)`) are captured and replayed
/// automatically. A rule that rebuilds the heading (`show heading: it => ..`)
/// cannot be, because nothing on a continuation frame matches it. Declare such
/// a rule through this function instead and it is applied on every frame:
///
/// ```typ
/// #show: decorate-heading.with(level: 2, it => block(width: 100%)[
///   #it
///   #line(length: 2em)
/// ])
/// ```
///
/// `decorate` receives the heading on the canonical frame and a block standing
/// in for it on the others, so it must treat its argument as opaque content to
/// place, not as an element whose fields it reads.
///
/// -> content
#let decorate-heading(
  /// The transformation, called with the heading or its stand-in.
  /// -> function
  decorate,
  /// The heading level the rule applies to, or `none` for every level.
  /// -> none | int
  level: none,
  /// The content the rule is in force for; supplied by `show:`.
  /// -> content
  body,
) = {
  if type(decorate) != function {
    fail("decorate-heading expects a function")
  }
  if level != none and type(level) != int {
    fail("decorate-heading level must be none or an integer")
  }
  show (if level == none { heading } else { heading.where(level: level) }): it => {
    pending-decorations.update(all => all + (decorate,))
    decorate(it)
  }
  body
}

// Capture composable heading styles without changing the queried heading.
// The scoped show rule returns the original element unchanged.
#let capture-heading-style(style-state, it) = context {
  style-state.update((
    decorations: (),
    text: (
      font: text.font,
      fallback: text.fallback,
      style: text.style,
      weight: text.weight,
      stretch: text.stretch,
      size: text.size,
      fill: text.fill,
      stroke: text.stroke,
      tracking: text.tracking,
      spacing: text.spacing,
      baseline: text.baseline,
      lang: text.lang,
      region: text.region,
      script: text.script,
      dir: text.dir,
      hyphenate: text.hyphenate,
      kerning: text.kerning,
      features: text.features,
    ),
    block: (
      above: block.above,
      below: block.below,
      sticky: block.sticky,
    ),
    alignment: align.alignment,
  ))
  pending-decorations.update(())
  it
  context {
    let decorations = pending-decorations.get()
    style-state.update(style => style + (decorations: decorations))
  }
}

// `canonical` is the real heading and `frame` the physical step being
// rendered: when the runtime names that step canonical (handout mode, where
// step 1 is never rendered), the real heading goes out instead of a
// continuation. A plane passes `canonical: none` and never owns a heading.
#let heading-continuation(style-state, body, canonical: none, frame: none) = context {
  if canonical != none and canonical-frame.get() == frame {
    return canonical
  }
  let style = style-state.get()
  if style == none {
    return body
  }
  if style.decorations.len() == 0 {
    return align(
      style.alignment,
      text(
        ..style.text,
        block(..style.block, body),
      ),
    )
  }
  // The stand-in is a plain block in the heading's place. The heading's block
  // spacing is stated as a set rule rather than on the stand-in, because a
  // show-set on `heading` reaches everything the decoration builds around it
  // as well. The list runs outermost first, so it is applied from the end.
  let stand-in = block(body)
  for decorate in style.decorations.rev() {
    stand-in = decorate(stand-in)
  }
  align(style.alignment, text(..style.text, {
    set block(..style.block)
    stand-in
  }))
}

#let contains-heading(value) = {
  // A speaker note never renders on a slide, so a heading written inside one
  // cannot destabilize outline entries between frames and must not trip the
  // temporal-heading guards.
  if is-note(value) {
    return false
  }
  if type(value) == content {
    if value.func() == heading {
      return true
    }
    return value.fields().values().any(contains-heading)
  }
  if type(value) == array {
    return value.any(contains-heading)
  }
  if type(value) == dictionary {
    return value.values().any(contains-heading)
  }
  false
}

// Replaces every heading in the value with its bare body, so a section title
// can be re-rendered elsewhere (the toc section variant, queryable section
// metadata) without minting duplicate outline entries or bookmarks.
#let strip-headings(value) = if type(value) != content {
  value
} else if value.func() == heading {
  value.body
} else if value.func() == [].func() {
  value.children.map(strip-headings).join()
} else {
  value
}

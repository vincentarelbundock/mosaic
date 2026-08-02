// Heading inspection, canonical style capture, and inert continuations.
#let typst-sequence = [].func()
#let typst-styled = text(red)[].func()

// Capture composable heading styles without changing the queried heading.
// The scoped show rule returns the original element unchanged.
#let capture-heading-style(style-state, it) = context {
  style-state.update((
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
  it
}

#let heading-continuation(style-state, body) = context {
  let style = style-state.get()
  if style == none {
    body
  } else {
    align(
      style.alignment,
      text(
        ..style.text,
        block(..style.block, body),
      ),
    )
  }
}

#let contains-heading(value) = {
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

#let resolve-state(state, visible, hidden, dimmed, removed) = {
  if state == "visible" {
    visible()
  } else if state == "hidden" {
    hidden()
  } else if state == "dimmed" {
    dimmed()
  } else {
    removed()
  }
}

#let apply-state(state, body) = resolve-state(
  state,
  () => body,
  () => hide(body),
  () => text(fill: gray, body),
  () => [],
)

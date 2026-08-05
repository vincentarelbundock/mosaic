#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.dark as m
#import "../mosaic/src/component/style.typ": role-colors
#import "../mosaic/src/themes/dark/tokens.typ" as dark-tokens

// Dark carries no component code of its own: the whole namespace is the base
// one, and the dark look arrives as a palette through setup.
#assert(m.components.image == mosaic.components.image)
#assert(m.components.callout == mosaic.components.callout)
#assert(m.components.quote == mosaic.components.quote)

#show: m.setup.with(base-size: 17pt)

// Every role resolves out of Dark's one flat palette: the role's own color is
// the accent, the deck text is the text, and the fill is that color tinted into
// Dark's canvas rather than a hand-written table entry.
#context {
  assert(role-colors("error", contextual: true).accent == dark-tokens.error)
  assert(role-colors("warning", contextual: true).text == dark-tokens.text)
  // `neutral` is the one role that is the deck surface rather than a tint.
  assert(role-colors("neutral", contextual: true).fill == dark-tokens.surface)
  // A tinted fill sits between the role color and the deck canvas, so it is
  // neither of them, and it follows the theme rather than the library default.
  let warning-fill = role-colors("warning", contextual: true).fill
  assert(warning-fill != dark-tokens.colors.warning)
  assert(warning-fill != dark-tokens.canvas)
  assert(warning-fill != role-colors("warning").fill)
}

#m.slide(layout: m.layouts.content(variant: "header-body"))[
  SEMANTIC COMPONENTS
][
  #grid(
    columns: (1fr, 1fr),
    gutter: 12pt,
    m.components.callout(role: "accent", title: [Information])[Telemetry connected.],
    m.components.callout(role: "warning", title: [Warning])[Capacity at 80%.],
    m.components.callout(role: "error", title: [Error])[Queue is stalled.],
    m.components.callout(accent: rgb("#bc8cff"), title: [Takeaway])[Prefer bounded work.],
    m.components.card[
      #m.components.badge(role: "accent")[API]
      #h(8pt)
      #m.components.progress()
    ],
  )

  #m.components.divider(title: [Evidence])
  #m.components.quote(
    attribution: [Grace Hopper],
    source: [Systems practice],
  )[The most dangerous phrase is: we've always done it this way.]
]

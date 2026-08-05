#import "@local/mosaic:0.0.1" as m
#import "../mosaic/src/component/style.typ": role-colors
#import "../mosaic/src/palettes.typ": dark

// The dark look is one palette handed to setup; no theme carries dark
// component code. Components resolve their paints out of that flat palette:
// the role's own color is the accent, the deck text is the text, and the fill
// is the role color tinted into the dark canvas rather than a hand-written
// table entry.
#show: m.setup.with(colors: dark, base-size: 17pt)

#context {
  assert(role-colors("error", contextual: true).accent == dark.error)
  assert(role-colors("warning", contextual: true).text == dark.text)
  // `neutral` is the one role that is the deck surface rather than a tint.
  assert(role-colors("neutral", contextual: true).fill == dark.surface)
  // A tinted fill sits between the role color and the deck canvas, so it is
  // neither of them, and it follows the palette rather than the library
  // default.
  let warning-fill = role-colors("warning", contextual: true).fill
  assert(warning-fill != dark.warning)
  assert(warning-fill != dark.canvas)
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

#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.dark as m
#import "../mosaic/src/component/style.typ": role as component-role
#import "../mosaic/src/themes/dark/tokens.typ" as dark-tokens

// Dark carries no component code of its own: the whole namespace is the base
// one, and the dark look arrives as a palette through setup.
#assert(m.components.image == mosaic.components.image)
#assert(m.components.callout == mosaic.components.callout)
#assert(m.components.quote == mosaic.components.quote)

#show: m.setup.with(base-size: 17pt)

// The semantic roles resolve to Dark's palette, including the roles the
// colors-only derivation never touches.
#context {
  assert(component-role("success", contextual: true) == dark-tokens.roles.success)
  assert(component-role("danger", contextual: true).accent == dark-tokens.error)
  // `accent` keeps Dark's own tinted fill rather than the deck surface.
  assert(component-role("accent", contextual: true).fill == rgb("#13233a"))
}

#m.slide(layout: m.layouts.content(variant: "header-body"))[
  SEMANTIC COMPONENTS
][
  #grid(
    columns: (1fr, 1fr),
    gutter: 12pt,
    m.components.callout(role: "information", title: [Information])[Telemetry connected.],
    m.components.callout(role: "success", title: [Success])[Deployment healthy.],
    m.components.callout(role: "warning", title: [Warning])[Capacity at 80%.],
    m.components.callout(role: "danger", title: [Danger])[Queue is stalled.],
    m.components.callout(role: "takeaway", title: [Takeaway])[Prefer bounded work.],
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

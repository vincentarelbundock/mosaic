#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.dark as m

#assert(m.components.image == mosaic.components.image)

#show: m.setup.with(base-size: 17pt)

#m.slide(layout: m.layouts.content(variant: "header-body"))[
  SEMANTIC COMPONENTS
][
  #grid(
    columns: (1fr, 1fr),
    gutter: 12pt,
    m.components.callout(kind: "information", title: [Information])[Telemetry connected.],
    m.components.callout(kind: "success", title: [Success])[Deployment healthy.],
    m.components.callout(kind: "warning", title: [Warning])[Capacity at 80%.],
    m.components.callout(kind: "danger", title: [Danger])[Queue is stalled.],
    m.components.callout(kind: "takeaway", title: [Takeaway])[Prefer bounded work.],
    m.components.frame[
      #m.components.label(role: "accent")[API]
      #h(8pt)
      #m.components.progress(current: 3, total: 5)
    ],
  )

  #m.components.divider(label: [Evidence])
  #m.components.quote(
    attribution: [Grace Hopper],
    source: [Systems practice],
  )[The most dangerous phrase is: we've always done it this way.]
]

#import "@local/mosaic:0.0.1" as m

// One flat palette. Naming a color here is the whole job: every component that
// takes a `role:` paints from these entries, so nothing below restates a color.
#show: m.setup.with(
  colors: (
    accent: rgb("#7c3aed"),
    warning: rgb("#b45309"),
  ),
)

#m.slide(layout: m.layouts.content(variant: "header-body"))[
  Components follow the palette
][
  #m.components.callout(role: "accent", title: [Method])[
    The percentile interval uses 10 000 resamples.
  ]

  #m.components.callout(role: "warning", title: [Caveat])[
    Coverage degrades when the statistic is not pivotal.
  ]

  Status markers pick up the same colors:
  #m.components.badge(role: "accent")[stable]
  #m.components.badge(role: "warning")[draft]
  #m.components.badge(role: "error")[deprecated]
]

#import "@local/mosaic:0.0.1" as m

#show: m.setup

== `components.card()`

#align(center + horizon)[
  #m.components.card(
    role: "accent",
    width: 75%,
    radius: 10pt,
    inset: 1.2em,
  )[
    #text(size: 1.4em, weight: "bold")[One dependable container]
    #linebreak()
    Shared geometry and styling for higher-level elements.
  ]
]

#m.slide(layout: m.grids.columns("a", "b"))[
  #m.components.card(
    width: 100%,
    height: 100%,
    radius: 12pt,
    inset: 1em,
  )[
    #lorem(24)
  ]
][
  #m.components.card(
    width: 100%,
    height: 100%,
    radius: 12pt,
    inset: 1em,
  )[
    #lorem(24)
  ]
]

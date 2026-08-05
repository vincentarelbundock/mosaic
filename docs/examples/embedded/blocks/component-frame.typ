#import "@local/mosaic:0.0.1" as m

#show: m.setup

== `components.frame()`

#align(center + horizon)[
  #m.components.frame(
    role: "information",
    width: 75%,
    style: (radius: 10pt, inset: 1.2em),
  )[
    #text(size: 1.4em, weight: "bold")[One dependable container]
    #linebreak()
    Shared geometry and styling for higher-level elements.
  ]
]

#m.slide(layout: m.grids.h("a", "b"))[
  #m.components.frame(
    width: 100%,
    height: 100%,
    style: (radius: 12pt, inset: 1em),
  )[
    #lorem(24)
  ]
][
  #m.components.frame(
    width: 100%,
    height: 100%,
    style: (radius: 12pt, inset: 1em),
  )[
    #lorem(24)
  ]
]

#import "@local/mosaic:0.0.1" as m

#show: m.setup

== `components.tag()`

#align(center + horizon)[
  #m.components.tag(
    role: "information",
    radius: 0pt,
    style: (text: (size: 1.35em, weight: "bold")),
  )[Square corners]
  #h(1em)
  #m.components.tag(
    role: "information",
    radius: 999pt,
    style: (text: (size: 1.35em, weight: "bold")),
  )[Rounded corners]
]

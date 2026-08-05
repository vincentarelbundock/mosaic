#import "@local/mosaic:0.0.1" as m

#show: m.setup

== `components.badge()`

#align(center + horizon)[
  #m.components.badge(
    role: "accent",
    radius: 0pt,
    text: (size: 1.35em, weight: "bold"),
  )[Square corners]
  #h(1em)
  #m.components.badge(
    role: "accent",
    radius: 999pt,
    text: (size: 1.35em, weight: "bold"),
  )[Rounded corners]
]

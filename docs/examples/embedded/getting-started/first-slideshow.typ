#import "@local/mosaic:0.0.1" as m

#show: m.setup

#m.slide(grid: m.layouts.title(
  title: [Getting started],
  variant: "image-background",
  image: (
    path: path("/docs/assets/images/bonsai.webp"),
    alt: "A pine bonsai",
  ),
  align: top + right,
  subtitle: [A first Mosaic deck],
))

= Content

== Bullet points

- Slides start with `==`.
- Sections start with `=`.
- Everything is static by default.

= Composition

== A rounded grid

#let card(fill) = block(
  width: 100%,
  inset: 0.65em,
  radius: 0.35em,
  fill: fill,
)[#lorem(8)]

#grid(
  columns: (1fr, 1fr),
  gutter: 0.6em,
  card(rgb("#e8f1fb")),
  card(rgb("#f8e8ee")),
  card(rgb("#e8f5ec")),
  card(rgb("#f7f0dd")),
)

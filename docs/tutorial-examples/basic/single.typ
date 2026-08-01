#import "@local/mosaic:0.0.1" as m

#show: m.setup

#m.slide(grid: m.layouts.title(
  [Getting started],
  variant: "image-background",
  image: (
    path: path("/docs/assets/images/bonsai.webp"),
    alt: "A pine bonsai",
  ),
  align: top + right,
  subtitle: [A first Mosaic deck],
))

== A figure

#align(center + horizon)[
  #figure(
    m.image(
      path("/docs/assets/images/bonsai.webp"),
      width: 55%,
      height: 10em,
      fit: "contain",
      alt: "A pine bonsai",
    ),
    caption: [A carefully shaped pine bonsai.],
  )
]

== Bullet points

- Slides start with `==`.
- Lists are ordinary Typst.
- Everything is static by default.

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

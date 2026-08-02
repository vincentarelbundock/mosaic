// Import Mosaic, then install its document-wide slide behavior.
#import "@local/mosaic:0.0.1" as m

#show: m.setup

// Use an explicit slide when you want a specialized layout. This title layout
// places the image behind the text and anchors that text in the top-right.
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

// A level-one heading starts a section slide.
= Content

// A level-two heading starts a regular content slide. The following content
// fills that slide until the next level-one or level-two heading.
== Bullet points

- Slides start with `==`.
- Sections start with `=`.
- Everything is static by default.

= Composition

== A rounded grid

// Slide bodies are ordinary Typst: define a reusable card, then arrange four
// instances with Typst's native grid function.
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

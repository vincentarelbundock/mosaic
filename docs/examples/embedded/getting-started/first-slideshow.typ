// Configure the deck once: identity, layouts, and a progress line.
#import "@local/mosaic:0.0.1" as m

#show: m.setup.with(
  title: [Getting started],
  subtitle: [A first Mosaic deck],
  authors: [Ada Lovelace],
  layouts: (
    content: m.layouts.content(variant: "header-body"),
    section: m.layouts.section(variant: "baseline")),
  foreground: align(bottom, m.components.progress(variant: "line")),
)

// The title layout reads the identity from setup, so it needs no body.
#m.slide(layout: "title")

// `=` starts a section slide; the text after it becomes its subtitle.
= Slides from headings

No `slide` call required

// `==` starts a content slide, filled until the next heading.
== Bullet points

- Slides start with `==`.
- Sections start with `=`.
- Everything is static by default.

= Pictures and columns

Explicit slides when a heading is not enough

// The image layout takes two blocks: header, then body.
#m.slide(
  layout: "image",
  variant: "right",
  image: path("/docs/assets/images/dog.webp"),
)[== A picture beside text][
  - The picture fills the right band.
  - The text keeps the left.
]

// Three blocks: header, left column, right column.
#m.slide(layout: "content", columns: 2)[== Two columns][
  First column
][
  Second column
]

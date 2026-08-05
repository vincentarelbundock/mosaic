// Import Mosaic, then configure the deck once: its identity, the layout every
// content slide will use, and a progress line on the foreground plane.
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

// The built-in title layout reads the identity declared in setup, so this
// slide needs no body.
#m.slide(layout: "title")

// A level-one heading starts a section slide; the text after it becomes the
// section's subtitle.
= Slides from headings

No `slide` call required

// A level-two heading starts a regular content slide. The following content
// fills that slide until the next level-one or level-two heading.
== Bullet points

- Slides start with `==`.
- Sections start with `=`.
- Everything is static by default.

= Pictures and columns

Explicit slides when a heading is not enough

// The image layout pairs a full-bleed picture with a header and body. The
// first positional block is the header, the second is the body.
#m.slide(
  layout: "image",
  variant: "right",
  image: path("/docs/assets/images/dog.webp"),
)[== A picture beside text][
  - The picture fills the right band.
  - The text keeps the left.
]

// Two columns on the configured content layout: header, left, right.
#m.slide(layout: "content", columns: 2)[== Two columns][
  First column
][
  Second column
]

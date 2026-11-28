# Get started

First, import Mosaic and apply its setup rule:

```typ
#import "@preview/mosaic:0.0.2" as m
#show: m.setup
```

`m.setup` applies the page and theme defaults and turns headings and explicit `m.slide` commands into slides; compiling the document as usual produces a PDF deck.

After `#show: m.setup`, every `==` starts a **content slide**: the heading becomes the title and the text that follows becomes its content. A single `=` starts an unnumbered **section slide** with a larger, centered title, and any text between it and the next `==` becomes that section's subtitle.

Most decks declare their shared settings once at the top with `m.setup.with(...)`: the deck's title and authors, the layout every content slide should use, and any recurring content such as a progress line. After that, the document is mostly headings, with explicit `m.slide` calls for slides a heading cannot express, such as a picture beside text or a two-column comparison.

The example below is a complete deck in that shape. It declares its title and authors once, opens with the built-in `title` layout, creates ordinary slides from headings, and finishes with two explicit slides: one `image` layout and one two-column content slide.

```typ
// Configure the deck once: identity, layouts, and a progress line.
#import "@preview/mosaic:0.0.2" as m

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
  image: path("/docs-src/assets/images/dog.webp"),
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
```

Read the [Concepts](../reference/concepts.md) page next: it defines the vocabulary this documentation uses and the anatomy every slide shares. The [Slides](../slides/content.md) section then takes each kind of slide in turn: ordinary [content](../slides/content.md), the [title](../slides/title.md) slide, [section](../slides/section.md) dividers, [image](../slides/image.md) slides, and [custom](../slides/custom.md) compositions built from named cells.

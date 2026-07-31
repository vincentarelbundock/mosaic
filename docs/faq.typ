#import "/.calepin/calepin.typ" as calepin
#import "/_includes/tutorial-gallery.typ": (
  thumbnail-gallery-items,
  verbatim-example,
)

#set document(title: [FAQ])
#metadata((
  title: "FAQ",
  tags: ("help", "questions"),
)) <website-metadata>

#title()

== Where are the themes?

Mosaic deliberately has no theme object. Where Beamer has themes, Mosaic has
`setup`, presets, and native Typst rules. Set deck-wide colors, spacing, and
features once through `m.setup`. Capture a reusable configuration as an
ordinary Typst value with `.with(...)`; such a value is called a preset:

```typ
#let brand = m.setup.with(
  colors: m.color.scheme("dark") + (
    accent: rgb("#e69f00"),
  ),
  features: (slide-number: true, progress: true),
)

#show: brand
```

Everything else, such as typography, headings, captions, and lists, is styled
with ordinary `set` and `show` rules after setup.

== Where do slide margins go?

`setup` uses a zero page margin. Put content spacing on the cells:

```typ
#show: m.setup

#let grid = m.grid.v(
  m.grid.cell("a"),
  m.grid.h("b", "c"),
)

#m.slide(
  grid,
  cell-styles: (
    a: (inset: 1.5em),
    b: (inset: 1.5em),
    c: (inset: 1.5em),
  ),
)[Top][Bottom left][Bottom right]
```

The named `inset` overrides keep content away from cell edges. The default inset is applied
uniformly to every side of every cell, so adjacent cells contribute one inset
each to the space between their content. An explicit inset overrides the
default. The grid's `gutter` adds space between cell surfaces and defaults
to `0pt`.

== Can headings create slides automatically?

Yes. `setup` detects headings automatically. A depth-one heading (`=`) creates
an unnumbered section slide, and a depth-two heading (`==`) begins a numbered
slide:

```typ
#import "@local/mosaic:0.0.1" as m

#show: m.setup.with(
  spacing: (inset: 1.5em),
)

= Methods

== Data

This is one logical slide.

== Model

#m.reveal[
  - Specify the model.
  - Estimate its parameters.
  - Examine the diagnostics.
]
```

== How do I customize automatic heading slides?

By default a `==` heading builds a slide with
`templates.default(variant: "header-body")`: the heading fills the header and
the following content fills the body. To give every automatic slide a different
look, with your own furniture, colors, or grid, pass an `auto-slide` function
to `m.setup`. It receives the heading and body as content and returns a
`m.slide(...)` command, so plain `==` markup can share the exact styling of your
explicit slides.

```typ
#let framed(title, body) = m.slide(
  grid: m.templates.default(
    variant: "header-body",
    inverted: ("header",),
    progress: "1",
  ),
)[#title][#body]

#show: m.setup.with(auto-slide: framed)

== Results

Routed through `framed`, so this `==` slide gets the inverted header bar and
progress indicator without a single `#slide` call.
```

The returned slide may use any grid, not only header-body. A single body cell
that merges the title and content, an image template, or a custom cell tree all
work. The one rule is Mosaic's usual one: the grid must accept as many body
blocks as the function passes it. Passing `none` (the default) keeps the
built-in header-body slide.

== How do I change the slide aspect ratio?

Mosaic supports the two presentation aspect ratios built into Typst:

- `"16-9"` is the default widescreen format.
- `"4-3"` is the traditional format.

Choose one with the `paper` argument.

#verbatim-example("basic/aspect-16-9.typ")
#verbatim-example("basic/aspect-4-3.typ")

#thumbnail-gallery-items(
  calepin.elements.gallery,
  (
    (
      "/assets/tutorials/basic/aspect-16-9-1.svg",
      "A widescreen 16:9 slide",
      [16:9],
    ),
    (
      "/assets/tutorials/basic/aspect-4-3-1.svg",
      "A traditional 4:3 slide",
      [4:3],
    ),
  ),
)

== How can I reuse slides and states?

Define a slide as an ordinary Typst function and call it wherever it should appear:

```typ
#let results-slide() = m.slide[
  == Results

  #m.reveal[
    - The estimate is positive.
    - The interval excludes zero.
    - The result is practically important.
  ]
]

#results-slide()

// Other slides...

#results-slide()
```

The second call creates another logical slide and reproduces the same
incremental sequence. The two calls use the same source, so later edits remain
synchronized.

To show only a selected state without repeating the full sequence, parameterize
the function or write a small summary slide containing that state.

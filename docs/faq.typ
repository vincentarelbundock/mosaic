#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": (
  example-source,
  thumbnail-gallery-items,
)

#set document(title: [FAQ])
#metadata((
  title: "FAQ",
  tags: ("help", "questions"),
)) <website-metadata>

#title()

== Where do slide margins go?

`setup` uses a zero page margin. Put content spacing on the cells with each cell's `inset`:

```typ
#show: m.setup

#let grid = m.grid.v(
  m.grid.cell("a", inset: 1.5em),
  m.grid.h(
    m.grid.cell("b", inset: 1.5em),
    m.grid.cell("c", inset: 1.5em),
  ),
)

#m.slide(layout: grid)[Top][Bottom left][Bottom right]
```

`inset` separates content from a cell's edges; adjacent cells each contribute their own inset. A grid `gutter` instead separates the cell surfaces and defaults to `0pt`.

== Can headings create slides?

Yes. After `#show: m.setup`, `=` starts an unnumbered section slide and `==` starts a numbered content slide:

```typ
#import "@local/mosaic:0.0.1" as m

#show: m.setup.with(
  spacing: (inset: 1.5em),
)

= Methods

== Data

This is one logical slide.

== Model

#m.steps.reveal[
  - Specify the model.
  - Estimate its parameters.
  - Examine the diagnostics.
]
```

See #link("basics.html#first-slideshow")[First slideshow] for a complete example.

== How do I customize content slides?

Set the `content` layout in `m.setup`. Explicit content slides and slides created with `==` will then use the same layout and recurring foreground content.

```typ
#show: m.setup.with(
  layouts: (
    content: m.layouts.content(variant: "header-body"),
  ),
  content: (
    foreground: [
      #place(bottom + right, dx: -1.25em, dy: -0.35em)[
        #m.components.progress(variant: "1")
      ]
    ],
  ),
)

// Invert the header bar for every content-layout slide.
#show label("mosaic-cell-header"): set text(fill: white)
#show label("mosaic-cell-header"): it => block(width: 100%, fill: black, it)

== Results

The content layout gives this `==` slide the inverted header bar and progress indicator without a single `#slide` call. ```

Any layout whose cells accept the automatic `header` and `body` content works. Themes provide a complete layout dictionary, and setup overrides may replace only the named layouts that differ; see #link("appearance.html#themes")[Appearance] and the
#link("api/setup.html")[Setup API].

== How do I change the slide aspect ratio?

Mosaic supports the two presentation aspect ratios built into Typst:

- `"16-9"` is the default widescreen format.
- `"4-3"` is the traditional format.

Choose one with the `paper` argument.

#example-source("faq/aspect-ratio-16-9")
#example-source("faq/aspect-ratio-4-3")

#thumbnail-gallery-items(
  calepin.elements.gallery,
  (
    (
      "/assets/examples/faq/aspect-ratio-16-9-1.svg",
      "A widescreen 16:9 slide",
      [16:9],
    ),
    (
      "/assets/examples/faq/aspect-ratio-4-3-1.svg",
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

  #m.steps.reveal[
    - The estimate is positive.
    - The interval excludes zero.
    - The result is practically important.
  ]
]

#results-slide()

// Other slides...

#results-slide()
```

Each call creates another logical slide with the same incremental sequence. To show only one state, parameterize the function or write a summary slide.

== How do I link to a slide?

Use native Typst labels and links. A label on a content slide becomes the link target directly:

```typ
== Results <results>

See #link(<details>)[the details slide]. ```

For an explicit slide, put labeled, zero-output metadata at the beginning of its content:

```typ
#m.slide[
  #metadata(none) <details>
  == Details

  Return to #link(<results>)[the results slide].
]
```

Typst writes these as internal PDF destinations, so Mosaic does not need a separate slide-ID or deep-link API. Use your own unique labels for navigation; the repeated `<mosaic-cell-ID>` labels identify cells for styling and are not slide IDs.

== How do I inspect overflowing cells?

Mosaic emits non-fatal metadata when a rendered cell is taller than its allocation. Query those records with:

```sh typst eval \
  'query(<mosaic-overflow-warning>).map(it => it.value)' \
  --in slides.typ
```

Each record identifies the slide, frame, cell, and measured height. Disable observation with `setup(overflow: "off")`; see the
#link("api/setup.html")[Setup API].

== How does Mosaic compare to Touying?

#link("https://github.com/touying-typ/touying")[Touying] and Mosaic both create presentations in Typst. Touying centers its workflow on themes and their configuration options. Mosaic centers its workflow on named grid cells and native Typst `set` and `show` rules. Touying is a good fit when an existing theme already matches the presentation. Mosaic is a good fit when you want to compose and style slides directly.

#table(
  columns: (auto, 1fr, 1fr),
  inset: 0.5em,
  table.header([Concern], [Mosaic], [Touying]),
  [Layout], [Composable grid trees], [Theme-defined structures],
  [Styling], [Native Typst rules], [Framework configuration],
  [Custom slides], [Ordinary functions and grids], [Theme methods receiving framework state],
  [Page control], [Native `set page`], [`config-page`; direct `set page` reserved],
)

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

`setup` uses a zero page margin. Put content spacing on the cells with each
cell's `inset`:

```typ
#show: m.setup

#let grid = m.grid.v(
  m.grid.cell("a", inset: 1.5em),
  m.grid.h(
    m.grid.cell("b", inset: 1.5em),
    m.grid.cell("c", inset: 1.5em),
  ),
)

#m.slide(grid)[Top][Bottom left][Bottom right]
```

`inset` separates content from a cell's edges; adjacent cells each contribute
their own inset. A grid `gutter` instead separates the cell surfaces and
defaults to `0pt`.

== Can headings create slides?

Yes. After `#show: m.setup`, a depth-one heading (`=`) writes an unnumbered
section slide, and a depth-two heading (`==`) writes a numbered heading
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

#m.steps.reveal[
  - Specify the model.
  - Estimate its parameters.
  - Examine the diagnostics.
]
```

== How do I customize heading slides?

Pass an `auto-slide` function to `m.setup`. It receives the heading and body and
returns an `m.slide` command, so a plain `==` heading slide can use your grid
and furniture.

```typ
#let framed(title, body) = m.slide(
  grid: m.layouts.default(variant: "header-body", progress: "1"),
  content: (header: title, body: body),
)

#show: m.setup.with(auto-slide: framed)

// Invert the header bar for every slide built on the default layout.
#show label("mosaic-cell-header"): set text(fill: white)
#show label("mosaic-cell-header"): it => block(width: 100%, fill: black, it)

== Results

Routed through `framed`, so this `==` slide gets the inverted header bar and
progress indicator without a single `#slide` call.
```

Any grid works; named cells keep title/body assignment independent of tree
order. The default `none` uses Mosaic's built-in header-body slide. Themes use
the same hook; see #link("appearance.html#themes")[Appearance] and the
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

Each call creates another logical slide with the same incremental sequence. To
show only one state, parameterize the function or write a summary slide.

== How do I inspect overflowing cells?

Mosaic emits non-fatal metadata when a rendered cell is taller than its
allocation. Query those records with:

```sh
typst eval \
  'query(<mosaic-overflow-warning>).map(it => it.value)' \
  --in slides.typ
```

Each record identifies the slide, frame, cell, and measured height. Disable
observation with `features: (overflow: "off")`; see the
#link("api/setup.html")[Setup API].

== How does Mosaic compare to Touying?

#link("https://github.com/touying-typ/touying")[Touying] is the most
established Typst presentation framework. The projects emphasize different
workflows:

#table(
  columns: (auto, 1fr, 1fr),
  inset: 0.5em,
  table.header([Concern], [Mosaic], [Touying]),
  [Layout], [Composable grid trees], [Theme-defined structures],
  [Styling], [Native Typst rules], [Framework configuration],
  [Reveals], [Explicit ranges and reducers], [Beamer-style markers],
  [Ecosystem], [Small and layout-focused], [Mature themes and integrations],
)

Choose Touying for its broad theme ecosystem and familiar Beamer conventions.
Choose Mosaic when layouts vary slide by slide and native Typst composition is
the priority. Mosaic's bundled themes remain copyable modules; see
#link("appearance.html#themes")[Appearance].

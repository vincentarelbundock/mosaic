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

= Can headings create slides?

Yes. After `#show: m.setup`, `=` starts an unnumbered section slide and `==` starts a numbered content slide. Text placed between a `=` and the next `==` becomes the section slide's subtitle:

```typ
#import "@local/mosaic:0.0.1" as m

#show: m.setup.with(
  spacing: (inset: 1.5em),
)

= Methods

What the data can and cannot support.

== Data

This is one slide.

== Model

#m.steps.reveal[
  - Specify the model.
  - Estimate its parameters.
  - Examine the diagnostics.
]
```

See #link("../start/first-deck.html")[First deck] for a complete example.

= How do I customize content slides?

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

Any layout with `header` and `body` cells works. A theme supplies all of the named layouts, and `setup(layouts:)` may replace only the ones that differ; see #link("../appearance/themes.html")[Themes] and the
#link("../api/setup.html")[Setup API].

= How can I reuse slides and states?

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

Each call creates another slide with the same incremental sequence. To show only one state, parameterize the function or write a summary slide.

= Can two slides share a title?

Yes. A sequence of slides that walks through one argument, one figure per slide, often repeats the same title so that the sequence reads as a single animation. Repeated headings collide in the outline and in link targets, so give each repeat its own label:

```typ
== Grade appeals

The valid and invalid reasons to appeal.

== Grade appeals #metadata(none) <appeals-2>

What happens after you appeal.
```

The labeled `metadata` produces no output; it only makes the heading unique. The same pattern works in the header block of an explicit slide: `[== Elasticity #metadata(none) <elasticity-3>]`.

= How do I link to a slide?

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

= Where do slide margins go?

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

= How do I change the slide aspect ratio?

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

= How do I inspect overflowing cells?

Mosaic records a warning when a cell's content is taller than the cell. Query those records with:

```sh typst eval \
  'query(<mosaic-overflow-warning>).map(it => it.value)' \
  --in slides.typ
```

Each record identifies the slide, frame, cell, and measured height. Set `setup(overflow: "error")` to fail the compile instead, naming every overflowing cell with the same slide and frame numbers the query reports, or `setup(overflow: "off")` to turn the check off; see the
#link("../api/setup.html")[Setup API].

To make the content fit instead of reporting it, give the cell a `fit:` mode: `m.layouts.content(fit: "auto")` scales and reflows a body column into the available space, and `m.grid.cell(id, fit: ...)` does the same for a hand-built cell. Fitted cells never trigger the warning.

= How does Mosaic compare to Touying?

#link("https://github.com/touying-typ/touying")[Touying] and Mosaic both create
presentations in Typst. Touying centers its workflow on themes and their
configuration options. Mosaic centers its workflow on named grid cells and
native Typst `set` and `show` rules.

#table(
  columns: (auto, 1fr, 1fr),
  inset: 0.5em,
  table.header([Concern], [Mosaic], [Touying]),
  [Layout], [Composable grid trees], [Theme-defined structures],
  [Styling], [Native Typst rules], [Framework configuration],
  [Custom slides], [Ordinary functions and grids], [Theme methods receiving framework state],
  [Page control], [Native `set page`], [`config-page`; direct `set page` reserved],
)

Touying is the most established Typst presentation framework. It works like
LaTeX Beamer: you pick a theme, the theme decides what slides look like, and
you adjust the result through the framework's configuration system. Colors,
title and author information, and page settings each have their own
configuration function, and the theme reads those values back when it draws
headers, footers, and title slides:

```typ
#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  config-colors(primary: rgb("#1a6b8a")),
  config-info(title: [My talk], author: [Author Name]),
)
```

This works well when a theme's options cover what you want. Enter your title
and author once and every theme knows where to display them, so switching
themes is often a one-line change. The cost is that each adjustment has its
own framework mechanism to discover: a different page background means
learning that `set page` is off limits (the framework resets it) and that
page changes go through `config-page`, while changing colors partway through
a deck means learning `touying-set-config`. The load grows most when you want
a slide the theme did not anticipate. Small tweaks fit through configuration,
but a genuinely different layout means writing a theme method that receives
the framework's internal state (called `self`), builds the header and footer
from it, and merges page settings before handing off. This is condensed from
Touying's own theme tutorial:

```typ
#let slide(title: auto, ..args) = touying-slide-wrapper(self => {
  let header(self) = {
    show: components.cell.with(fill: self.colors.primary, inset: 1em)
    utils.call-or-display(self, self.store.title)
  }
  self = utils.merge-dicts(self, config-page(header: header))
  touying-slide(self: self, ..args)
})
```

Writing this requires several Touying concepts at once: the `self` state,
wrapper functions, configuration merging, and the utility helpers. The
tutorial is upfront about it, saying Touying "opts for functionality over
simplicity," and suggests that most users instead copy a built-in theme file
and edit it.

Mosaic also ships layouts and themes, and you can get beautiful, full-featured slides with little effort. But Mosaic's core is different than Touying's: any slide can be assembled from a grid of named cells and styled with the same `set` and `show` rules you would use in any Typst document. There is less to learn because Mosaic adds almost nothing of its own. After `m.setup`, styling is ordinary Typst; the one new idea is that every cell carries a label you can target with a rule:

```typ
#show: m.setup
#set page(fill: rgb("#111827"))
#set text(fill: white)
#show label("mosaic-cell-header"): set text(size: 1.4em)
```

If you know how `set` and `show` rules work in Typst, you already know how to
style a Mosaic deck, including scoping a rule to a single slide. A one-off
slide is just a slide with a different grid, and a reusable design is an
ordinary function with no internal state to receive and nothing to register.
The cell IDs are arbitrary names you choose; each one becomes a
`mosaic-cell-ID` label that ordinary rules can target:

```typ
#let framed(title, body) = m.slide(
  layout: m.grid.v("banner", "copy"),
  content: (banner: title, copy: body),
)

#show label("mosaic-cell-banner"): set text(size: 1.4em, weight: "bold")
#show label("mosaic-cell-copy"): set align(left + horizon)

#framed([Results])[The body.]
```

The same grid can become the configured `content` layout, which also drives
every `==` heading slide. A Mosaic theme is a passive definition plus an exact
facade and callable layout namespace; the bundled themes are copyable starting
points (see #link("../appearance/themes.html")[Themes]).

Touying is a good fit when an existing theme already matches the presentation.
Mosaic is a good fit when you want to compose and style slides directly.
Mosaic's incremental commands were heavily influenced by Touying, and parts of
its counter freezing and cell fitting are adapted from it. The
#link("../acknowledgments.html")[Acknowledgments] page records those debts in
full.

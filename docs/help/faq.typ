#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": (
  embedded-example,
  example-source,
  thumbnail-gallery,
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
  foreground: [
    #place(bottom + right, dx: -1.25em, dy: -0.35em)[
      #m.components.progress(variant: "1")
    ]
  ],
)

// Invert the header bar for every content-layout slide.
#show label("mosaic-cell-header"): set text(fill: white)
#show label("mosaic-cell-header"): it => block(width: 100%, fill: black, it)

== Results

The content layout gives this `==` slide the inverted header bar and progress indicator without a single `#slide` call. ```

Any layout with `header` and `body` cells works. A theme supplies all of the named layouts, and `setup(layouts:)` may replace only the ones that differ; see #link("../appearance/themes.html")[Themes] and the
#link("../api/setup.html")[Setup API].

= How do I invert a slide's colors?

Pair each ground with the text color that reads against it, and apply both halves in the same rule. `m.surface` fills the cell's own block and a neighboring `set text` colors the content inside it, so a helper that takes a `(fill, text)` pair can repaint any set of cells:

#embedded-example(
  calepin.elements.gallery,
  "faq/color-inversion",
  frames: 2,
  title: "One layout rendered on a light ground and on a dark one",
  renderer: thumbnail-gallery,
)

The same helper inverts a single slide, a run of slides, or a whole deck, depending on where you place the `#show:` rule. Scope it inside a block for one slide, or write it once after `m.setup` to change the baseline. To invert the full bleed rather than the cells, add `#set page(fill: ..)`; the background and foreground planes take the same rules through the `<mosaic-background>` and `<mosaic-foreground>` labels.

Mosaic does not derive the text color from the fill. Two reasons, both practical. Mid-tone grounds sit where an automatic flip is least reliable: a muted sage such as `rgb("#aebdb3")` reads as "light" to a luminance rule, but white on it measures 1.8:1, well under the 4.5:1 that body text wants. And a cell's declared fill is often not what the viewer sees behind the text, because an image, scrim, or background plane covers it. Naming the pair keeps that judgment with the author, where a real slide can be looked at.

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

#let grid = m.grids.rows(
  m.grids.cell("a", inset: 1.5em),
  m.grids.columns(
    m.grids.cell("b", inset: 1.5em),
    m.grids.cell("c", inset: 1.5em),
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

A warning means the slide holds more than it can show. The remedy is editorial: cut a bullet, split the slide in two, or move to a layout with more room. Mosaic deliberately offers no automatic shrink-to-fit for body content, because a deck whose type size is decided slide by slide loses the scale that holds it together.

When a single indivisible block is the problem, a wide table or a chart, scale that one block with `m.fit` and leave the deck's typography alone:

```typ
#m.slide[
  == Regression results
  #m.fit(my-table)
]
```

`m.fit` measures the block against the space it was given and scales it geometrically, so the surrounding layout accounts for the new size. It shrinks only unless `grow: true` is passed, and it takes no hand-picked factor, so the block stays within the cell when the table gains a row. See the #link("../api/slides.html")[Slides API].

A fitted block cannot overflow, so it no longer appears in the overflow records.

= How does Mosaic compare to Touying?

#link("https://github.com/touying-typ/touying")[Touying] is the most established Typst presentation framework. It is mature and well documented, it has powerful animation support, and the largest collection of themes, including many contributed by its community.

In that context, it is natural to ask how it differs from Mosaic. The table below summarizes some of the core philosophical differences between the two packages, and the rest of this section explains where they come from.

#table(
  columns: (auto, 1fr, 1fr),
  inset: 0.5em,
  table.header([Concern], [Mosaic], [Touying]),
  [Layout], [Built-in layouts or custom grid], [The shape specified by the theme],
  [Slide cells], [Named and ordered], [Ordered],
  [Styling], [The same `set` and `show` rules of any Typst document], [Framework-specific arguments passed to Touying functions],
  [Custom slides], [An ordinary function], [Theme code that plugs into the framework],
  [Settings], [Fixed once, when the deck starts], [Carried along, and any slide can change them],
  [Themes], [Interchangeable; all offer the same commands], [Each brings its own commands],
  [Size], [Around 30 commands and 19 setup options], [Around 150 commands and 110 options],
  [Reveals], [Five commands], [A large animation system],
)

For an ordinary slide deck Touying and Mosaic are very similar. In both cases, you import the package, pick a theme, write headings, and get slides. The theme supplies the typography, the colors, the title slide, and the section dividers. Like Touying, Mosaic ships layouts for the slides most decks need: a title, a section divider, a page of content, a full-bleed image, etc. The two packages start to diverge when a deck needs something that available themes do not provide.

Touying is a framework, and the work goes through it. It exports roughly 150 commands and accepts about 110 configuration options.

Changing something therefore starts with finding the option that controls it. The page background is an example: `set page` has no effect, because the framework overrides it, and the change goes through `config-page`. Within a slide, the `composer` argument determines how the body is divided, and it takes either a list of column widths or a function that arranges the pieces. The header, the footer, and the page belong to the theme, so changing them for one slide means overriding the theme, and a different layout means writing a slide function that receives the framework's settings, draws the header and footer, and passes the rest along. Touying's tutorial says the package "opts for functionality over simplicity" and recommends copying a built-in theme file and editing it.

The settings are carried through the document, and any slide can modify them. The option functions accept names they do not recognize, so a misspelled option has no effect and reports no error. A theme is code and provides its own slide commands, so a deck that calls one theme's `focus-slide` does not compile under a theme without it.

Mosaic, in contrast, is a thin layer on Typst. It has about thirty commands in eight groups, and `m.setup` takes nineteen options, read once when the deck starts and unchanged afterward. A slide is a grid of cells, each cell has a name, and those names are the only concept the package adds. Everything else is done with the `set` rules, `show` rules, and functions of the language itself:

```typ
#import "@local/mosaic:0.0.1" as m

#show: m.setup
#set page(fill: rgb("#111827"))
#set text(fill: white)
#show label("mosaic-cell-header"): set text(size: 1.4em)
```

Where you place a rule determines what it covers, as in any Typst document. When no built-in layout fits, you write the grid: rows split into columns, columns split into rows, for as long as the slide needs. A layout you want to reuse is a function:

```typ
#let framed(title, body) = m.slide(
  layout: m.grids.rows("banner", "copy"),
  cells: (banner: title, copy: body),
)

#show label("mosaic-cell-banner"): set text(size: 1.4em, weight: "bold")
#show label("mosaic-cell-copy"): set align(left + horizon)

#framed([Results])[The body.]
```

A Mosaic theme is a description of colors and layouts, and all themes provide the same commands, so changing a theme changes the appearance only. Both packages ship usable themes, and Mosaic's are meant to be copied and edited (see #link("../appearance/themes.html")[Themes]).

Touying's reveals are more capable than Mosaic's. Besides `pause` and `meanwhile`, it can jump between marked points in a slide, repeat a slide with a counter the slide can read, animate equations, and reveal a CeTZ or Fletcher drawing one piece at a time. Mosaic has five commands for step-by-step content and no equivalent for animated drawings.

Touying is a reasonable choice when an existing theme matches the presentation, or when the deck depends on its animations. Mosaic is a reasonable choice for building and styling slides directly in Typst.

Mosaic's incremental commands were heavily influenced by Touying, and parts of its counter freezing and cell fitting are adapted from it. The #link("../acknowledgments.html")[Acknowledgments] page records those debts in full.

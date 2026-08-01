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

The per-cell `inset` keeps content away from cell edges. The default inset is applied
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
`layouts.default(variant: "header-body")`: the heading fills the header and
the following content fills the body. To give every automatic slide a different
look, with your own furniture, colors, or grid, pass an `auto-slide` function
to `m.setup`. It receives the heading and body as content and returns a
`m.slide(...)` command, so plain `==` markup can share the exact styling of your
explicit slides.

```typ
#let framed(title, body) = m.slide(
  grid: m.layouts.default(variant: "header-body", progress: "1"),
)[#title][#body]

#show: m.setup.with(auto-slide: framed)

// Invert the header bar for every slide built on the default layout.
#show label("mosaic-cell-header"): set text(fill: white)
#show label("mosaic-cell-header"): it => block(width: 100%, fill: black, it)

== Results

Routed through `framed`, so this `==` slide gets the inverted header bar and
progress indicator without a single `#slide` call.
```

The returned slide may use any grid, not only header-body. A single body cell
that merges the title and content, an image layout, or a custom cell tree all
work. The one rule is Mosaic's usual one: the grid must accept as many body
blocks as the function passes it. Passing `none` (the default) keeps the
built-in header-body slide. Every theme on the
#link("themes.html")[Themes] page registers its `default` layout as
`auto-slide` in exactly this way.

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


== How does Mosaic compare to Touying?

#link("https://github.com/touying-typ/touying")[Touying] is the most
established presentation framework for Typst, and it is an excellent project.
It follows the Beamer tradition: a presentation is built around a theme, and
the theme is an object that bundles colors, headers, footers, a title slide,
and special slide constructors. Users pick a theme such as `metropolis` or
`university`, then adjust it through a unified configuration API
(`config-info`, `config-colors`, `config-methods`). This design has real
strengths. Switching themes requires few changes to a document, the ecosystem
of community themes on Typst Universe is large, and Touying ships integrations
for tools such as CeTZ, Fletcher, and pdfpc speaker notes.

Mosaic starts from a different premise: the fundamental unit of a slide is not
a theme but a layout. Every Mosaic slide is a grid, a small tree of horizontal
and vertical splits whose cells hold content. Semantic layouts such as
`layouts.title` or `layouts.image` are thin layers that resolve to the same
canonical grid trees, so there is one layout model to learn and it composes all
the way down. Touying instead delegates layout to each theme; a theme defines
how its header, footer, and body fit together, and stepping outside that
structure means writing or modifying a theme. In Mosaic, an unusual layout is
just another grid, written inline with the same primitives as every other
slide.

The second difference is how much machinery sits between your document and
Typst. Touying implements its own object model: a `self` dictionary threads
through themes and callbacks, and dynamic content can require callback-style
functions with a manually specified `repeat` count. This buys Touying
considerable power, but it also means learning a framework within the
language. Mosaic keeps its surface deliberately small. A Mosaic theme is a
plain Typst module rather than an object, and there is no `self`; deck-wide
settings flow through a single `setup` function, reusable configurations are
ordinary Typst values built with `.with(...)`, and typography, headings, and
captions are styled with native `set` and `show` rules. If you already know
Typst, you already know most of how to style a Mosaic deck.

The two projects also treat incremental content differently. Touying offers
Beamer-style `#pause` and `#meanwhile` markers plus `only`, `uncover`, and
`alternatives`, which will feel immediately familiar to Beamer users. Mosaic
provides declarative constructors, `on`, `reveal`, `replace`, and `reduce`,
that attach explicit step ranges to content. The step count is discovered
automatically, visibility is data rather than position, and the same
constructors work anywhere in a grid, including in backgrounds and
foregrounds.

Which should you choose? If you want a broad theme gallery and Beamer-like
conventions, Touying is a mature and capable choice. Mosaic is for
presentations where layout carries the message: full-bleed images,
edge-to-edge color fields, and slide designs that vary from one slide to the
next. Its zero-margin pages, cell insets, background and foreground planes,
and uniform grid model make that kind of design direct rather than an act of
theme surgery, while everything that is not layout remains plain Typst. Mosaic
still offers ready-made looks: a few polished themes ship inside the package
under `m.themes`, and each is a single readable module you can copy and own;
see the #link("themes.html")[Themes] page.

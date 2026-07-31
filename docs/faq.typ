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

== Do I need named animation waypoints?

Usually not. Mosaic's `on()` already expresses when content is visible, and
ordinary Typst variables can give important ranges meaningful names:

```typ
#import "@local/mosaic:0.0.1" as m

#let steps = (
  evidence: "2-",
  conclusion: "3-",
)

#m.slide[
  == Results

  The question is visible from the beginning.

  #m.on(steps.evidence)[
    The evidence appears next.
  ]

  #m.on(steps.conclusion)[
    The conclusion appears last.
  ]
]
```

Here `on()` controls visibility while Typst supplies the names and reusable
values. These names do not renumber themselves. If inserting an earlier step
changes the animation timeline, update the corresponding range values in one
place.

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

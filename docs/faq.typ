#set document(title: [FAQ])
#metadata((
  title: "FAQ",
  tags: ("help", "questions"),
)) <website-metadata>

#title()

== How do I choose a grid?

Build the grid with `m.grid.h`, `m.grid.v`, and `m.grid.t`, then pass it as the
first argument to `m.slide()`:

```typ
#show: m.setup

#m.slide(m.grid.h("left", "right"))[
  Left
][
  Right
]
```

The `grid:` parameter is equivalent:

```typ
#m.slide(grid: m.grid.h("left", "right"))[Left][Right]
```

Mosaic validates the composed grid and checks that the supplied body count
matches its consuming cells.

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

Yes. `setup` detects headings automatically:

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

A source-depth-one heading (one equals sign) creates an unnumbered, centered
section slide. A source-depth-two heading begins an ordinary numbered slide.
Deeper headings remain content within the current slide. These boundaries
continue to use source depth when `heading(offset: ...)` changes the resolved
native level.

Each source heading remains one canonical native Typst heading across
incremental frames. Later frames repeat only its body, preventing duplicate
queries, counters, outline entries, bookmarks, labels, and accessibility
semantics. Mosaic automatically reapplies the canonical heading's active text,
block-spacing, and alignment styles to those continuations, including
heading show-set rules. Headings cannot be placed inside temporal content or
a temporally controlled grid cell.

Foreground furniture can retrieve the active native heading from an ambient
context:

```typ
#m.deck(
  foreground: context {
    let section = m.current-heading()
    if section != none { section.body }
  },
)
```

Automatic slides require a single empty cell in the deck's default grid.
Setup also accepts explicit `m.slide` calls between automatic slides.
It rejects section body text and visible content before the first
structural heading. Presentations that use custom `m.grid.h()` or `m.grid.v()`
grids should use explicit `m.slide(grid: ...)` calls instead.

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
values.

These names do not renumber themselves. If inserting an earlier step changes
the animation timeline, update the corresponding range values in one place.

== How can I reuse an earlier slide?

Define the slide as an ordinary Typst function and call it wherever it should
appear:

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

== Can I replay only one frame?

Not automatically. A reusable function re-renders the complete logical slide.
To show only a selected state, parameterize the function or write a small
summary slide containing that state.

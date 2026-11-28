# Components

`m.components` provides reusable Typst content to place inside cells, or inside any native Typst composition. None of these create slides or grids on their own; they are values you place in a cell, a background, a foreground, or any native Typst composition. A component is transparent to Mosaic's own commands: a pause, a step, or a note written inside a `card`, `callout`, `quote`, `badge`, `divider`, or `figure` works as it does in the cell around it, and a dimmed component mutes its fill and border along with its text. Each function has an independent example and gallery. One member, `m.components.progress()`, is documented with the deck infrastructure on the [Footer and progress](../presenting/footer.md) page; it is ordinary content all the same and can sit in any cell.

> **Requires Mosaic 0.0.3.** Steps and notes inside a component, and the quote's rail and native arguments, are new. The examples on this page compile under the released version as they stand. This is the development version, which is not on Typst Universe yet: a deck that uses it imports `@local/mosaic:0.0.3` rather than the released `@preview/mosaic:0.0.2`. See [Install](../start/install.md).

## `card()`

Wrap content in a clipped, bordered panel.

```typ
#import "@preview/mosaic:0.0.2" as m

#show: m.setup

== `components.card()`

#align(center + horizon)[
  #m.components.card(
    role: "accent",
    width: 75%,
    radius: 10pt,
    inset: 1.2em,
  )[
    #text(size: 1.4em, weight: "bold")[One dependable container]
    #linebreak()
    Shared geometry and styling for higher-level elements.
  ]
]

#m.slide(layout: m.grids.columns("a", "b"))[
  #m.components.card(
    width: 100%,
    height: 100%,
    radius: 12pt,
    inset: 1em,
  )[
    #lorem(24)
  ]
][
  #m.components.card(
    width: 100%,
    height: 100%,
    radius: 12pt,
    inset: 1em,
  )[
    #lorem(24)
  ]
]
```

## `callout()`

Emphasize content with a colored side stripe and an optional title.

```typ
#import "@preview/mosaic:0.0.2" as m

#show: m.setup

== `components.callout()`

#align(center + horizon)[
  #m.components.callout(
    [Null-only papers remain rare.],
    accent: rgb("#7c3aed"),
    title: [Main result],
  )
]
```

## `badge()`

Create a compact inline badge with configurable corners and text styling.

```typ
#import "@preview/mosaic:0.0.2" as m

#show: m.setup

== `components.badge()`

#align(center + horizon)[
  #m.components.badge(
    role: "accent",
    radius: 0pt,
    text: (size: 1.35em, weight: "bold"),
  )[Square corners]
  #h(1em)
  #m.components.badge(
    role: "accent",
    radius: 999pt,
    text: (size: 1.35em, weight: "bold"),
  )[Rounded corners]
]
```

## `quote()`

Typeset a borderless quotation with an optional attribution. A `role:` other than `neutral`, or an explicit `accent:`, draws a rail down its left edge in that color; a plain quotation has none. The component is a superset of Typst's own `quote`, so `block:`, `quotes:`, and a label passed as `attribution:` keep their native meaning.

```typ
#import "@preview/mosaic:0.0.2" as m

#show: m.setup
#set page(fill: rgb("#f3f0e9"))

== `components.quote()`

#align(center + horizon)[
  #m.components.quote(
    [#text(size: 1.25em, style: "italic")[
      “A useful slide makes the relationship visible.”
    ]],
    attribution: [Ada Example],
    source: [Field notes],
    inset: 1.3em,
  )
]
```

## `divider()`

Separate content with a horizontal line, with or without a label.

```typ
#import "@preview/mosaic:0.0.2" as m

#show: m.setup

== `components.divider()`

#block(width: 85%)[
  #lorem(12)
  #v(0.6em)
  #m.components.divider(title: [Evidence])
  #v(0.6em)
  #lorem(12)
  #v(0.6em)
  #m.components.divider()
  #v(0.6em)
  #lorem(12)
]
```

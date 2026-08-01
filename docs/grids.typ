#import "/.calepin/calepin.typ" as calepin
#import "/_includes/tutorial-gallery.typ": slideshow, verbatim-example

#set document(title: [Grids])
#metadata((title: "Grids")) <website-metadata>

#let grid-thumbnail(path, alt) = {
  if sys.inputs.at("calepin-target", default: "paged") == "html" {
    html.elem("img", attrs: (
      src: path,
      alt: alt,
      style: "display:block;width:33.333%;height:auto;margin:1rem auto;",
    ))
  } else {
    align(center, image(path, width: 33.333%, alt: alt))
  }
}

#title()

Every #link("layouts.html")[layout] returns a deferred customized-grid
dictionary. When passed to `m.slide`, it resolves into the same horizontal and
vertical split model exposed through `m.grid`. Work with grids directly when a
slide does not fit a semantic layout.

A grid is a tree of rectangular cells. Each cell receives one block of slide
content. `v` stacks cells vertically, `h` places them side by side, and either
split can be nested.

= Overflow warnings

Mosaic measures each rendered cell at its allocated width. When the natural
content height exceeds the available height, it emits a non-fatal metadata
diagnostic for each overflowing logical-slide cell and physical frame.
Observation is enabled by default. Disable it for a deck with:

```typ
#show: m.setup.with(
  features: (overflow: "off"),
)
```

Query the resulting diagnostics with:

```sh
typst eval \
  'query(<mosaic-overflow-warning>).map(it => it.value)' \
  --in slides.typ
```

Each record identifies the logical slide, physical frame, cell ID or
structural path, available height, measured height, and a `mosaic:` message.
Compilation continues.

Only vertical overflow is reported; horizontal overflow is not. Disable
observation if measurement of cells containing complex introspection triggers
Typst layout-convergence warnings.

= Grids with `h()` and `v()`

The shortest way to create a custom grid is to describe how its cells split
the available space. Use `m.grid.h` for cells placed next to one another and
`m.grid.v` for cells stacked from top to bottom. Each string is a cell ID.
Start with short, descriptive IDs; they make both the structure and later
cell-specific changes easy to follow.

Import Mosaic under a short local alias. Native Typst `h()` and `v()` remain
available for spacing:

```typ
#import "@local/mosaic:0.0.1" as m
```

== Horizontal

This grid has three equal-width columns. Read the arguments from left to right:

```typ
m.grid.h("a", "b", "c")
```

#grid-thumbnail(
  "/assets/tutorials/grids/hv-thumbnails-1.svg",
  "Three equal columns",
)

`m.grid.h` gives each child the same share of the width by default. Adding a fourth
ID would create four equal columns; removing one would leave two.

== Vertical

Use `m.grid.v` when the same three cells should run from top to bottom. Read its
arguments in visual order:

```typ
m.grid.v("a", "b", "c")
```

#grid-thumbnail(
  "/assets/tutorials/grids/hv-thumbnails-2.svg",
  "Three equal rows",
)

Here, every child receives an equal share of the height. The important
difference is therefore simple: `m.grid.h` divides width, while `m.grid.v`
divides height.

== Nesting

An argument does not have to be a string. It can be another grid. In the next
example, `m.grid.h` first divides the space into left and right halves. Cell `a`
occupies the left half, while the nested `m.grid.v` divides the right half between
`b` and `c`:

```typ
m.grid.h("a", m.grid.v("b", "c"))
```

#grid-thumbnail(
  "/assets/tutorials/grids/hv-thumbnails-3.svg",
  "One column beside two stacked cells",
)

The outermost function describes the largest division. Work inward one split
at a time: choose the outer direction, then replace any cell that needs
another division with a nested `m.grid.h` or `m.grid.v`.

The same idea can create a regular two-by-two grid. The outer `m.grid.v`
creates two rows, and each nested `m.grid.h` divides one row into two columns:

```typ
m.grid.v(m.grid.h("a", "b"), m.grid.h("c", "d"))
```

#grid-thumbnail(
  "/assets/tutorials/grids/hv-thumbnails-4.svg",
  "A two-by-two grid",
)

== Complex grid

For a larger grid, sketch the largest bands first. This example begins with
three vertical bands: a title, a main area, and a footer. The main area is
then divided into two columns, and those columns contain their own nested
splits:

```typ
m.grid.v(
  "title",
  m.grid.h(
    m.grid.v(
      "col0",
      "sidebar-note",
    ),
    m.grid.v(
      m.grid.h("col1", "col2"),
      m.grid.h(
        "chart",
        m.grid.v("legend", "annotation"),
      ),
    ),
  ),
  m.grid.h("footer", "status", "page"),
)
```

#grid-thumbnail(
  "/assets/tutorials/grids/hv-thumbnails-5.svg",
  "A deeply nested grid",
)

Even this larger grid follows the same rule: each `m.grid.h` describes one
horizontal split, and each `m.grid.v` describes one vertical split. Indentation
makes the tree visible in the source, so align nested calls and give every
closing parenthesis its own level.

= Grid sizes (tracks)

By default, every direct child of `m.grid.h` or `m.grid.v` receives a `1fr`
track. This makes siblings equal. The same namespace provides `m.grid.t` when a
child should use a different track size:

```typ
#import "@local/mosaic:0.0.1" as m
```

Wrap only the child whose track changes. Here, `a` receives two thirds of the
width and `b` receives one third:

```typ
m.grid.h(m.grid.t(2fr, "a"), "b")
```

#grid-thumbnail(
  "/assets/tutorials/grids/tracks-1.svg",
  "A two-to-one horizontal split",
)

A relative length works the same way on a vertical split. The first row below
uses 25% of the height, while the second row receives the remaining space:

```typ
m.grid.v(m.grid.t(25%, "a"), "b")
```

#grid-thumbnail(
  "/assets/tutorials/grids/tracks-2.svg",
  "A 25% top row",
)

Wrap every child when the intended ratio is easier to read explicitly:

```typ
m.grid.h(m.grid.t(1fr, "a"), m.grid.t(2fr, "b"), m.grid.t(1fr, "c"))
```

#grid-thumbnail(
  "/assets/tutorials/grids/tracks-3.svg",
  "A one-to-two-to-one horizontal split",
)

Track sizes accept Typst's native `auto`, fixed-length, relative-length, and
fractional values. Use `auto` for a content-sized track, a length such as `3cm`
for a fixed track, a percentage for a relative track, and `fr` units to divide
the remaining space proportionally.

= Grid → slide

Pass the completed grid as the first argument to `slide`, then provide one
content block for each cell. The blocks follow the string IDs in source order:
left to right within `m.grid.h`, top to bottom within `m.grid.v`, and
recursively through nested grids.

This complete example creates three slides: three columns, two rows, and a
title–columns–footer grid.

#verbatim-example("grids/grid-to-slide.typ")

#slideshow(
  calepin.elements.gallery,
  "grids/grid-to-slide",
  3,
  "Three slides built from horizontal and vertical grids",
)

= Assigning content by name

Positional blocks are terse, but a reader must trace the grid's traversal order
to know which block lands where, and rearranging the grid moves content even
when the IDs stay put. For a custom grid with several supplied cells, assign
content by ID through the `cells` dictionary instead:

```typ
#let comparison = m.grid.h(
  m.grid.v("heading", "left"),
  "right",
)

#m.slide(
  grid: comparison,
  cells: (
    heading: [Heading],
    left: [Left argument],
    right: [Right argument],
  ),
)
```

Dictionary order does not matter; each entry is matched to its cell by ID. This
makes the cell ID the single handle for a cell: `m.grid.cell("body")` defines
it, `cells: (body: [...])` fills it, and `label("mosaic-cell-body")` styles it.

Every content-bearing cell must have an entry, and an entry naming an unknown
cell or a fixed-content cell is a reported error. `cells:` and positional
blocks cannot be mixed in one call. Keep positional blocks for the ordinary
one-cell slide and for small grids where source order is already obvious.

= Styling named cells

Grid constructors describe structure and stable cell identities. Cells carry
no appearance of their own. Every rendered cell is a single block labeled
`<mosaic-cell-ID>`, so you style cells with ordinary Typst `set` and `show`
rules keyed on that label:

```typ
#show label("mosaic-cell-copy"): set align(left + horizon)
#show label("mosaic-cell-copy"): set text(fill: black, size: 1.1em)
#show label("mosaic-cell-copy"): it => block(
  width: 100%,
  height: 100%,
  fill: white,
  it,
)

#m.slide(m.grid.h("copy", "image"))[Copy][Image]
```

There is no styling dictionary to learn: font, size, color, and alignment are
`set text`, `set par`, and `set align`; fills, strokes, rounded corners, and
insets are the `block` you wrap the cell in. The one structural knob that
lives on the cell itself is `inset`, because padding affects layout
measurement:

```typ
#m.grid.cell("image", inset: 0pt)
```

A full-height cell (`1fr` or a fixed track) fills its region when the wrapping
block asks for `height: 100%`. A content-sized cell (an `auto` track) should
omit the height so its fill hugs the content.

Precedence is ordinary rule nesting. Mosaic's `setup` and any theme establish
baseline cell rules; a rule you write after `#show: m.setup` overrides them
deck-wide; and a rule scoped inside a block around a single `m.slide` call
overrides them for that slide only:

```typ
#[
  #show label("mosaic-cell-body"): set align(center + horizon)
  #m.slide[Centered for this slide only]
]
```

= Reusable grids and styles

Save the structure in a variable, and bundle the cell rules in a transformer,
when several slides should share both. Apply the transformer once and every
following slide that uses those cell IDs picks the rules up:

```typ
#let grid = m.grid.h(
  m.grid.t(2fr, "a"),
  m.grid.cell("b"),
)
#let styled(body) = {
  show label("mosaic-cell-b"): it => block(
    width: 100%,
    height: 100%,
    fill: blue,
    it,
  )
  body
}

#show: styled
#m.slide(grid)[Left][Right]
```

#verbatim-example("grids/reusable.typ")

#slideshow(
  calepin.elements.gallery,
  "grids/reusable",
  2,
  "One grid and one set of reusable cell rules shared by two slides",
)

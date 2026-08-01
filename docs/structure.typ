#import "/.calepin/calepin.typ" as calepin
#import "/_includes/tutorial-gallery.typ": (
  slideshow,
  thumbnail-gallery,
  verbatim-example,
)

#set document(title: [Structure])
#metadata((title: "Structure")) <website-metadata>

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

A Mosaic slide is a grid of cells. Build a grid directly with `m.grid` when a
slide needs a custom shape, or reach for a *layout* — a named, ready-made grid
for a familiar structure — and pass it to `m.slide(grid: ...)`. Either way you
fill cells with content and style them separately with native Typst rules; see
#link("appearance.html")[Appearance] for the styling model.

A grid is a tree of rectangular cells. `v` stacks cells vertically, `h` places
them side by side, and either split can be nested.

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
child should use a different track size. Wrap only the child whose track
changes. Here, `a` receives two thirds of the width and `b` receives one third:

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

Track sizes accept Typst's native `auto`, fixed-length, relative-length, and
fractional values. Use `auto` for a content-sized track, a length such as `3cm`
for a fixed track, a percentage for a relative track, and `fr` units to divide
the remaining space proportionally.

= Filling cells

Pass the completed grid as the first argument to `slide` and provide one
content block per content-bearing cell. Positional blocks follow the cell IDs
in source order: left to right within `m.grid.h`, top to bottom within
`m.grid.v`, and recursively through nested grids.

#verbatim-example("grids/grid-to-slide.typ")

#slideshow(
  calepin.elements.gallery,
  "grids/grid-to-slide",
  3,
  "Three slides built from horizontal and vertical grids",
)

Positional blocks are terse, but a reader must trace the traversal order to
know which block lands where, and rearranging the grid moves content even when
the IDs stay put. Whenever a slide fills more than one cell, prefer the `cells`
dictionary — it assigns content by ID, so the mapping is explicit and
order-independent:

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
one-cell slide; reach for `cells:` as soon as a slide fills more than one. It is
the form Mosaic's own layout factories and automatic `==` slides use
internally.

A cell needs fixed content only when the grid, not the slide, owns it — an
`image` or a logo. Give such a cell `content:` in the grid; it then consumes no
slide body:

```typ
#m.grid.cell("logo", content: image("logo.svg"))
```

= Layouts

A layout returns a ready-made grid. Choose a function and, when available, a
`variant`, then pass the result to `m.slide(grid: ...)`. The common pattern is
to bind a slide function that combines the grid with its slide options, then
reuse it with different content:

```typ
#let myslide = m.slide.with(
  grid: m.layouts.default(variant: "header-body"),
  colors: m.color.scheme("dark"),
)

#myslide(cells: (header: [== Slide title], body: [Slide content]))
```

This keeps structural options on the layout constructor, slide behavior such as
`colors`, `background`, and `foreground` on `m.slide.with`, and individual calls
focused on content. The `default` layout's cells are `header`, `body` (or
`body-1`, `body-2`, … for multiple columns), and `footer`. Each layout's cells are labeled `<mosaic-cell-ID>`, so their
appearance is native rules; see #link("appearance.html")[Appearance]. Full
signatures live in the #link("api/layouts.html")[layouts API].

== `default()`

Creates a grid with one of four named cell structures. `variant` accepts `"body"`,
`"header-body"`, `"body-footer"`, or `"header-body-footer"`; the complete
`"header-body-footer"` structure is the default. `columns` controls the number
of body cells, while `tracks` optionally sets their relative or fixed widths.
Mosaic uses `"header-body"` for automatic slides created with `==`. For an
explicit titled slide, write `==` in the header block: this keeps normal Typst
heading styling and registers the heading with outlines. Set `progress` to
`"1/1"`, `"1"`, `"circle"`, or `"line"` to add a progress indicator on the slide
foreground; it follows the slide-local accent color.

The variant determines which named cells are present: `header`, `body`, and
`footer` for the full structure, just `body` for `"body"`, and so on. Fill them
with `cells: (header: …, body: …, footer: …)`, or positionally in that order.
`columns` divides the body into equal columns by default (`body-1`, `body-2`,
…); set `tracks` to one native track size per column to weight them.

#verbatim-example("layouts/default-full.typ")
#thumbnail-gallery(
  calepin.elements.gallery,
  "layouts/default-full",
  1,
  "A slide with header, body, and footer cells",
)

The `header`, `body` (or `body-1`, `body-2`, …), and `footer` cells are styled
with native rules. Fill a cell, invert it against the scheme, or place an image
behind its content — all through its label:

#verbatim-example("layouts/default-inverted.typ")
#thumbnail-gallery(
  calepin.elements.gallery,
  "layouts/default-inverted",
  1,
  "A default slide with an inverted header and footer",
)

Header and footer cells are content-sized: wrapped text expands their height and
leaves the rest to the body. Bundle a reusable look in a transformer and apply
it once with `#show:`, so every slide on the default layout shares it:

#verbatim-example("layouts/default-custom.typ")
#thumbnail-gallery(
  calepin.elements.gallery,
  "layouts/default-custom",
  2,
  "Slides made with a reusable custom look",
)

== `author()` and `title()`

`m.author(name, affiliations: (), email: none, orcid: none, corresponding:
false)` creates a validated author object shared by every title variant. `name`
is required; `affiliations` pairs a stable `id` with a visible `name`; email
syntax and the ORCID checksum are validated; and a corresponding author must
provide an email or ORCID.

`m.layouts.title` creates a complete opening slide. The title text is the first
positional argument and the layout supplies every cell, so the surrounding
`m.slide` consumes no blocks. Variants are `"academic"`, `"left-aligned"`,
`"centered-stack"`, `"accent-block"`, and the image variants `"image-left"`,
`"image-right"`, `"image-top"`, `"image-bottom"`, and `"image-background"`.
Every variant accepts `subtitle`, `authors`, and `date`; `"academic"` adds the
affiliation legend and contact line. Image variants require `image` (native
content, a path string, or a `path`/`alt`/`fit` dictionary); `"image-background"`
places the image behind the `title` cell, so darken the image and recolor the
title with `show label("mosaic-cell-title"): set text(fill: white)` for
light-on-dark compositions.

#verbatim-example("layouts/title.typ")
#thumbnail-gallery(
  calepin.elements.gallery,
  "layouts/title",
  9,
  "Nine structural title variants with inline academic metadata and images",
)

== `section()`

Creates a section-divider grid. The sole slide body is the section name;
`subtitle`, `number`, and `image` add context. Variants are `plain` and the same
five image variants as `title()`. Directional variants use two visual-order
`tracks`; `"image-background"` places the image behind the `section` cell.

#verbatim-example("layouts/section.typ")
#thumbnail-gallery(calepin.elements.gallery, "layouts/section", 7, "Section divider variants")

== `image()`

An image-first layout with no header or footer. `"full"` gives the image the
whole body without inset; `"figure"` contains it within the slide inset; and
`"left"`, `"right"`, `"top"`, and `"bottom"` pair a full-bleed image cell with a
companion body. Set `path` to let Mosaic place the image at `100%` with
`fit: "cover"` (override with `"contain"` or `"stretch"`); without `path`, the
image cell is an ordinary body so native `image(...)` content can supply advanced
options. Split variants take two visual-order `tracks`; the cells are named
`image` and `body`.

#thumbnail-gallery(calepin.elements.gallery, "layouts/image-full", 1, "Full image")
#thumbnail-gallery(calepin.elements.gallery, "layouts/image-left", 1, "Image beside a companion body")

== `table()`

Wraps a native Typst table or other tabular content. The table is content inside
a `table` cell; optional surrounding rows use the IDs `table-title`,
`highlight`, `caption`, and `source`.

#verbatim-example("layouts/table.typ")
#thumbnail-gallery(calepin.elements.gallery, "layouts/table", 4, "Table metadata configurations")

= Overflow warnings

Mosaic measures each rendered cell at its allocated width. When the natural
content height exceeds the available height, it emits a non-fatal metadata
diagnostic for each overflowing cell and frame. Observation is on by default;
disable it with `#show: m.setup.with(features: (overflow: "off"))`. Query the
diagnostics with:

```sh
typst eval \
  'query(<mosaic-overflow-warning>).map(it => it.value)' \
  --in slides.typ
```

Each record identifies the logical slide, physical frame, cell ID or structural
path, available and measured height, and a `mosaic:` message. Compilation
continues. Only vertical overflow is reported.

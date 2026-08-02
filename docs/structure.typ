#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": (
  embedded-example,
  thumbnail-gallery,
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
slide needs a custom shape, or reach for a *layout* (a named, ready-made grid
for a familiar structure) and pass it to `m.slide(grid: ...)`. Either way you
fill cells with content and style them separately with native Typst rules; see
#link("appearance.html")[Appearance] for the styling model.

A grid is a tree of rectangular cells. `v` stacks cells vertically, `h` places
them side by side, and either split can be nested.

= Grids with `h()` and `v()`

Describe a custom grid by splitting the available space. `m.grid.h` places
cells side by side; `m.grid.v` stacks them. Each string is a cell ID. Import
Mosaic under a short alias so native Typst `h()` and `v()` remain available:

```typ
#import "@local/mosaic:0.0.1" as m
```

Three strings produce three equal-width columns:

```typ
m.grid.h("a", "b", "c")
```

#grid-thumbnail(
  "/assets/examples/structure/grid-splits-1.svg",
  "Three equal columns",
)

Use `m.grid.v` for equal-height rows instead:

```typ
m.grid.v("a", "b", "c")
```

#grid-thumbnail(
  "/assets/examples/structure/grid-splits-2.svg",
  "Three equal rows",
)

Any child can be another grid. Here the outer horizontal split gives `a` the
left half, while a nested vertical split stacks `b` and `c` on the right:

```typ
m.grid.h("a", m.grid.v("b", "c"))
```

#grid-thumbnail(
  "/assets/examples/structure/grid-splits-3.svg",
  "One column beside two stacked cells",
)

Read a grid from the outside inward: choose the largest split first, then
replace any child that needs another division with a nested `h` or `v`. Keep
descriptive IDs and indentation so the tree remains visible in source.

= Grid sizes (tracks)

By default, every direct child of `m.grid.h` or `m.grid.v` receives a `1fr`
track. Wrap a child with `m.grid.t` when it needs another size. Here `a`
receives two thirds of the width and `b` one third:

```typ
m.grid.h(m.grid.t(2fr, "a"), "b")
```

#grid-thumbnail(
  "/assets/examples/structure/grid-tracks-1.svg",
  "A two-to-one horizontal split",
)

Tracks accept native `auto`, fixed lengths, percentages, and `fr` values. The
#link("api/grid.html")[Grid API] lists exact accepted forms and diagnostics.

= Filling cells

Pass the completed grid as the first argument to `slide` and provide one
content block per content-bearing cell. Positional blocks follow the cell IDs
in source order: left to right within `m.grid.h`, top to bottom within
`m.grid.v`, and recursively through nested grids.

#embedded-example(
  calepin.elements.gallery,
  "structure/filling-cells",
  frames: 3,
  title: "Three slides built from horizontal and vertical grids",
)

Positional blocks are useful for a one-cell slide. For multiple cells, prefer
the `cells` dictionary: IDs make assignment explicit and independent of tree
order.

```typ
#let comparison = m.grid.h(
  m.grid.v("heading", "left"),
  "right",
)

#m.slide(
  grid: comparison,
  content: (
    heading: [Heading],
    left: [Left argument],
    right: [Right argument],
  ),
)
```

The cell ID is its single handle: `m.grid.cell("body")` defines it,
`content: (body: [...])` fills it, and `label("mosaic-cell-body")` styles it. Every
content-bearing cell must be supplied; unknown IDs and mixing cell entries with
positional bodies are errors.

When the grid owns fixed content such as an image or logo, put it directly on
the cell; it then consumes no slide body:

```typ
#m.grid.cell("logo", content: image("logo.svg"))
```

= Layouts

A layout is a ready-made grid. Pass it to `m.slide`, or bind it once with
`m.slide.with` and reuse the resulting slide function:

```typ
#let accent = rgb("#e69f00")
#set page(fill: rgb("#111827"))
#set text(fill: rgb("#f3f4f6"))

#let myslide = m.slide.with(
  grid: m.layouts.default(
    variant: "header-body",
    accent: accent,
  ),
)

#myslide(content: (header: [== Slide title], body: [Slide content]))
```

Keep structure and drawn decoration on the layout, slide behavior on `m.slide`,
and appearance in native `set` and `show` rules. Every layout cell has a
`<mosaic-cell-ID>` label; see #link("appearance.html")[Appearance]. Exact
variants, cell IDs, and arguments live in the
#link("api/layouts.html")[Layouts API].

== `default()`

Use `default()` for ordinary body slides, optionally with a header, footer,
multiple columns, or progress indicator. Mosaic also uses its header-body form
for `==` heading slides.

#embedded-example(
  calepin.elements.gallery,
  "structure/default-layout-full",
  frames: 1,
  title: "A slide with header, body, and footer cells",
  renderer: thumbnail-gallery,
)

Style its header, body, and footer labels with native rules:

#embedded-example(
  calepin.elements.gallery,
  "structure/default-layout-inverted",
  frames: 1,
  title: "A default slide with an inverted header and footer",
  renderer: thumbnail-gallery,
)

Bundle reusable cell rules in a transformer so every default slide shares them:

#embedded-example(
  calepin.elements.gallery,
  "structure/default-layout-custom",
  frames: 2,
  title: "Slides made with a reusable custom look",
  renderer: thumbnail-gallery,
)

== `title()`

Use `title()` for an opening slide with optional subtitle, authors, date, and
image. It includes ordinary, academic, accent, and image compositions; title
metadata belongs to the layout, so the surrounding `m.slide` needs no body.

#embedded-example(
  calepin.elements.gallery,
  "structure/title-layout",
  frames: 9,
  title: "Nine structural title variants with inline academic metadata and images",
  renderer: thumbnail-gallery,
)

== `section()`

Use `section()` for a section divider with optional subtitle, number, or image.

#embedded-example(
  calepin.elements.gallery,
  "structure/section-layout",
  frames: 7,
  title: "Section divider variants",
  renderer: thumbnail-gallery,
)

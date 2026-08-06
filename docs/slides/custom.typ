#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example, thumbnail-gallery
#import "/_includes/pdf-slideshow.typ": pdf-slideshow
#import "/_includes/site.typ": asset-url

#set document(title: [Custom slides])
#metadata((title: "Custom")) <website-metadata>

// One step of the canonical semantic-slide example, shown through the same
// PDF slideshow treatment as every other embedded example. The preview image
// is that step's frame; the dialog pages through the whole walkthrough.
#let semantic-frames = 5
#let semantic-thumbnail(frame, alt) = {
  if sys.inputs.at("calepin-target", default: "paged") == "html" {
    pdf-slideshow(
      asset-url("assets/examples/basics/semantic-slide.pdf"),
      asset-url(
        "assets/examples/basics/semantic-slide-" + str(frame) + ".svg",
      ),
      "pdf-slideshow-basics-semantic-slide-" + str(frame),
      alt,
      semantic-frames,
      alt + ", step " + str(frame) + " of " + str(semantic-frames),
    )
  } else {
    thumbnail-gallery(
      calepin.elements.gallery,
      "basics/semantic-slide",
      1,
      alt,
      start: frame,
      columns: 1,
      show-captions: false,
    )
  }
}

#title()

When no built-in layout fits, write the slide's arrangement yourself. A custom slide names its own cells by purpose, such as `header`, `body`, `footer`, `aside`, or `notes`. This is *semantic* structure: content and styling refer to what each cell means instead of where it appears.

Build a custom slide in three separate layers: define its named grid, assign content to those names, and style the labeled cells with native Typst rules. The walkthrough below grows one slide through all three. The sections after it are the reference for each layer.

= Walkthrough

== One named cell

Start with one named cell and pass it to `slide` as the layout.

```typ
#let single = m.grids.cell("main")

#m.slide(
  layout: single,
  cells: (main: [A custom slide starts with one named cell.]),
)
```

#semantic-thumbnail(1, "A slide containing one named cell")

== Split the grid

`m.grids.columns` places cells side by side. Each key in `cells:` matches one cell ID.

```typ
#let split = m.grids.columns("main", "aside")

#m.slide(
  layout: split,
  cells: (
    main: [The main argument],
    aside: [Supporting evidence],
  ),
)
```

#semantic-thumbnail(2, "The slide split into two equal columns")

== Nest splits and size tracks

Splits nest directly: `rows` stacks the sidebar cells, `track` assigns their proportions, and `columns` combines the sidebar with the main cell.

```typ
#let composition = m.grids.columns(
  m.grids.track(2fr, "main"),
  m.grids.track(1fr, m.grids.rows(
    m.grids.track(2fr, "notes"),
    m.grids.track(1fr, "source"),
  )),
)

#m.slide(
  layout: composition,
  cells: (
    main: [The main argument],
    notes: [Two parts notes],
    source: [One part source],
  ),
)
```

#semantic-thumbnail(3, "A two-thirds main cell beside a vertically split sidebar")

== Add content

The grid remains unchanged while the `cells:` dictionary receives ordinary Typst markup: headings, lists, emphasis, figures, equations, or any custom content.

```typ
#m.slide(
  layout: composition,
  cells: (
    main: [
      == Composition

      - Name every cell.
      - Keep structure independent of content.
    ],
    notes: [
      *Evidence*

      #lorem(8)
    ],
    source: [#text(size: 0.65em)[Source: example data]],
  ),
)
```

#semantic-thumbnail(4, "The grid filled with ordinary Typst content")

== Style the cells

Once the cells and content are in place, target each cell by its label. `m.surface` paints the cell, while `set align` positions its content.

```typ
#show label("mosaic-cell-main"): m.surface(fill: rgb("#7fa8cc"))
#show label("mosaic-cell-main"): set align(left + horizon)
#show label("mosaic-cell-notes"): m.surface(fill: rgb("#85b892"))
#show label("mosaic-cell-source"): m.surface(fill: rgb("#c9a75e"))
```

See #link("../appearance/styling.html#content-rules-and-surface-rules")[Styling cells] for the full styling model.

== Built-in layouts are grids too

A built-in layout resolves to a grid of named cells like any other, so the same `cells:` dictionary fills it. Assign one to a binding and pass it as the layout when you want a familiar structure without giving up named assignment:

```typ
#let content-layout = m.layouts.content(variant: "header-body")

#m.slide(
  layout: content-layout,
  cells: (
    header: [== Content layout],
    body: [A familiar header-and-body structure.],
  ),
)
```

#semantic-thumbnail(5, "A built-in content layout filled through named cells")

= Grids with `columns()` and `rows()`

Describe a custom grid by splitting the available space. `m.grids.columns` places cells side by side; `m.grids.rows` stacks them. Each string is a cell ID. Import Mosaic under a short alias so the grid constructors stay namespaced and native Typst `columns()` remains available:

```typ
#import "@preview/mosaic:0.0.1" as m
```

Assign the grid to a binding, then pass it to `m.slide` through `layout:`. The slide's positional bodies fill the cells in source order:

#embedded-example(
  calepin.elements.gallery,
  "structure/grid-columns",
  title: "Three equal-width columns",
  renderer: thumbnail-gallery,
  columns: 1,
  show-captions: false,
)

Use `m.grids.rows` for equal-height rows instead:

#embedded-example(
  calepin.elements.gallery,
  "structure/grid-rows",
  title: "Three equal-height rows",
  renderer: thumbnail-gallery,
  columns: 1,
  show-captions: false,
)

Each example on this page outlines its cells so the structure is visible. Those outlines are nothing but ordinary label rules, described in #link("../appearance/styling.html")[Styling cells]: they open every listing and are no part of the grid, which is the `#m.grids` tree alone.

= Nesting

Any child of a split can be another grid, so a region can carry its own division. Here the outer `columns` gives `a` the left half and stacks `b` and `c` on the right:

#embedded-example(
  calepin.elements.gallery,
  "structure/grid-nested",
  title: "One column beside a stacked pair",
  renderer: thumbnail-gallery,
  columns: 1,
  show-captions: false,
)

Two stacked `columns` splits make a 2 x 2 arrangement:

#embedded-example(
  calepin.elements.gallery,
  "structure/grid-quadrants",
  title: "A two-by-two arrangement",
  renderer: thumbnail-gallery,
  columns: 1,
  show-captions: false,
)

Splits nest to any depth. Read a grid from the outside inward: choose the largest split first, then replace any child that needs another division with a nested `columns` or `rows`. Keep descriptive IDs and indentation so the tree stays visible in source:

#embedded-example(
  calepin.elements.gallery,
  "structure/grid-dashboard",
  title: "Three bands, the middle one divided twice",
  renderer: thumbnail-gallery,
  columns: 1,
  show-captions: false,
)

= Grid sizes (tracks)

By default, every direct child of `m.grids.columns` or `m.grids.rows` receives a `1fr` track. Wrap a child with `m.grids.track` when it needs another size:

#embedded-example(
  calepin.elements.gallery,
  "structure/grid-track-fraction",
  title: "A two-thirds split",
  renderer: thumbnail-gallery,
  columns: 1,
  show-captions: false,
)

Tracks accept native `auto`, fixed lengths, percentages, and `fr` values:

#embedded-example(
  calepin.elements.gallery,
  "structure/grid-track-banner",
  title: "A fixed-height banner over a body",
  renderer: thumbnail-gallery,
  columns: 1,
  show-captions: false,
)

Fractions compose, so three tracks can center a double-width column:

#embedded-example(
  calepin.elements.gallery,
  "structure/grid-track-center",
  title: "A centered double-width column",
  renderer: thumbnail-gallery,
  columns: 1,
  show-captions: false,
)

The #link("../api/grids.html")[Grid API] lists the exact accepted forms and their diagnostics.

= Filling cells

A slide accepts cell content in two distinct forms. Use positional content blocks (`[...][...]`) for a short grid whose traversal order is obvious, or use the named `cells:` dictionary to assign content by cell ID. Do not mix the two forms in one slide. Both forms work for a custom grid and for a built-in layout alike.

== Positional content with `[][]`

Place content blocks directly after the `m.slide(...)` call. Each pair of brackets is one positional body: `[a][b][c]` supplies three bodies. Mosaic matches them to cell IDs in source order, left to right within columns, top to bottom within rows, and recursively through nested grids.

```typ
#m.slide(layout: m.grids.columns("a", "b", "c"))[a][b][c]
```

#embedded-example(
  calepin.elements.gallery,
  "structure/filling-cells",
  frames: 3,
  title: "Positional bodies assigned to horizontal and vertical grids",
)

This compact form is especially useful for a one-cell slide. In a larger or reusable grid, positional meaning can become hard to see after the grid changes.

== Named content with `cells:`

Pass a dictionary to the named `cells:` argument to associate each body with an explicit cell ID. Assignment then remains independent of the grid's traversal order. In the example below the same IDs also anchor the styling: one `show` rule per cell label tints each cell, which is why the grid structure stays visible in the rendered slide.

#embedded-example(
  calepin.elements.gallery,
  "content/named-content",
  frames: 1,
  title: "Three bodies assigned explicitly by cell ID",
)

The cell ID connects all three layers: `m.grids.cell("body")` defines the cell, `cells: (body: [...])` fills it, and `label("mosaic-cell-body")` styles it. Content-bearing cells are optional and resolve to empty content when omitted; unknown IDs are errors.

== Fixed cell content

When a grid owns fixed content such as an image or logo, put it directly on the cell. Fixed cell content needs no positional body or `cells:` entry:

```typ
#m.grids.cell("logo", content: image("logo.svg"))
```

= Refine a layout

Any named argument `slide` does not recognize is a field of the selected layout. So a single slide can change one aspect of the configured layout without restating it:

```typ
#m.slide(layout: "title", variant: "academic")
#m.slide(layout: "section", number: [03])[Methods]
#m.slide(layout: "image", variant: "right", image: path("fig/photo.jpg"))[== Title][Body]
#m.slide(columns: 2)[== Comparison][Left column][Right column]
```

This differs from passing `m.layouts.title(variant: "academic")`, which *replaces* the configured layout. Named arguments *refine* it: whatever the theme or `m.setup` set for that layout, such as an accent color or a background image, survives. Only the fields you name change.

The two forms are mutually exclusive on one slide. With an explicit `m.layouts.*` value, pass the fields to that constructor instead:

```typ
// Refines the configured title layout.
#m.slide(layout: "title", variant: "academic")

// Replaces it; the fields go to the constructor.
#m.slide(layout: m.layouts.title(variant: "academic"))
```

Field names are checked against the selected layout, so `m.slide(layout: "title", columns: 2)` fails at compile time rather than being silently ignored. Fields also require a layout chosen by name: if `m.setup` configures that layout as a raw grid rather than an `m.layouts.*` value, there are no fields to refine and Mosaic says so. The #link("../api/layouts.html")[Layouts API] lists the fields each layout accepts.

= Replace or reuse a layout

To replace a named layout throughout a deck, configure it once in `m.setup`:

```typ
#show: m.setup.with(layouts: (
  section: m.layouts.section(variant: "image-background", image: "chapter.jpg"),
))
```

A custom grid goes in the same place, so a deck can send every `==` slide through a composition of your own:

```typ
#show: m.setup.with(layouts: (content: composition))
```

To reuse a layout for selected slides instead, bind it with `m.slide.with`:

```typ
#let myslide = m.slide.with(
  layout: m.layouts.content(
    variant: "header-body",
  ),
)

#myslide(cells: (header: [== Slide title], body: [Slide content]))
```

= What cells hold

A cell does not resize its content: a body larger than its cell is drawn past the edge. #link("../presenting/overflow.html")[Overflow and fitting] covers how to detect that and how `m.fit` scales one block into the space its cell gives it.

Cells hold ordinary Typst content. The #link("../content/images.html")[Content] section collects what most often goes inside them: images, the reusable `m.components` library, and math.

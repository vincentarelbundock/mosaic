#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example

#set document(title: [Filling cells])
#metadata((title: "Filling cells")) <website-metadata>

#title()

A slide accepts cell content in two distinct forms. Use positional content blocks (`[...][...]`) for a short grid whose traversal order is obvious, or use the named `content:` dictionary to assign content by cell ID. Do not mix the two forms in one slide.

= Positional content with `[][]`

Place content blocks directly after the `m.slide(...)` call. Each pair of brackets is one positional body: `[a][b][c]` supplies three bodies. Mosaic matches them to cell IDs in source order, left to right within `m.grid.h`, top to bottom within `m.grid.v`, and recursively through nested grids.

```typ
#m.slide(layout: m.grid.h("a", "b", "c"))[a][b][c]
```

#embedded-example(
  calepin.elements.gallery,
  "structure/filling-cells",
  frames: 3,
  title: "Positional bodies assigned to horizontal and vertical grids",
)

This compact form is especially useful for a one-cell slide. In a larger or reusable grid, positional meaning can become hard to see after the grid changes.

= Named content with `content:`

Pass a dictionary to the named `content:` argument to associate each body with an explicit cell ID. Assignment then remains independent of the grid's traversal order. In the example below the same IDs also anchor the styling: one `show` rule per cell label tints each cell, which is why the grid structure stays visible in the rendered slide.

#embedded-example(
  calepin.elements.gallery,
  "content/named-content",
  frames: 1,
  title: "Three bodies assigned explicitly by cell ID",
)

The cell ID connects all three layers: `m.grid.cell("body")` defines the cell, `content: (body: [...])` fills it, and `label("mosaic-cell-body")` styles it. Content-bearing cells are optional and resolve to empty content when omitted; unknown IDs are errors.

= Fixed cell content

When a grid owns fixed content such as an image or logo, put it directly on the cell. Fixed cell content needs no positional body or `content:` entry:

```typ
#m.grid.cell("logo", content: image("logo.svg"))
```

Cells hold ordinary Typst content. The #link("../content/images.html")[Content] section collects what most often goes inside them: images, the reusable `m.components` library, and math.

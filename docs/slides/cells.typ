#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example

#set document(title: [Filling cells])
#metadata((title: "Filling cells")) <website-metadata>

#title()

A slide accepts cell content in two distinct forms. Use positional content blocks (`[...][...]`) for a short grid whose traversal order is obvious, or use the named `content:` dictionary to assign content by cell ID. Do not mix the two forms in one slide.

= Positional content with `[][]`

Place content blocks directly after the `m.slide(...)` call. Each pair of brackets is one positional body: `[a][b][c]` supplies three bodies. Mosaic matches them to cell IDs in source order, left to right within `m.grids.h`, top to bottom within `m.grids.v`, and recursively through nested grids.

```typ
#m.slide(layout: m.grids.h("a", "b", "c"))[a][b][c]
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

The cell ID connects all three layers: `m.grids.cell("body")` defines the cell, `content: (body: [...])` fills it, and `label("mosaic-cell-body")` styles it. Content-bearing cells are optional and resolve to empty content when omitted; unknown IDs are errors.

= Fixed cell content

When a grid owns fixed content such as an image or logo, put it directly on the cell. Fixed cell content needs no positional body or `content:` entry:

```typ
#m.grids.cell("logo", content: image("logo.svg"))
```

= Fitting a block to its cell

A cell does not resize its content. A body larger than its cell is drawn past the edge and #link("../help/faq.html#how-do-i-inspect-overflowing-cells")[recorded as an overflow]. `m.fit` scales one block into the space its cell gives it:

```typ
#m.fit(generated-list)
```

It measures the block, scales it geometrically, and reflows the surrounding layout around the new size. Shrinking is the default. `grow: true` also scales content up, which is how a single number or word fills a cell.

The block is offered the cell's width first, so text and lists wrap and are then scaled only if they are still too tall. A table or diagram given a narrower width rearranges itself instead of shrinking, so `wrap: false` measures and scales it as written.

`width:` and `height:` fit to part of the region instead of all of it, and take a length, ratio, or fraction. A fitted block cannot overflow, so it no longer appears in the overflow records.

Measuring a block means holding it inside a closure, which the slide runtime cannot look into. `m.pause`, `m.steps`, and `m.note` are found by walking the slide's content, so inside a fitted block they would be invisible: the reveals would collapse into one frame and the notes would never reach the speaker output. `m.fit` reports that as an error instead. Keep them outside the fitted block, or fit each revealed part on its own.

#embedded-example(
  calepin.elements.gallery,
  "content/fit-block",
  frames: 2,
  title: "A table scaled to its cell, and display type grown to fill one",
)

Cells hold ordinary Typst content. The #link("../content/images.html")[Content] section collects what most often goes inside them: images, the reusable `m.components` library, and math.

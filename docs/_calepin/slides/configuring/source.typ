#import "/_calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example

#set document(title: [Configuring layouts])
#metadata((title: "Configuring layouts")) <website-metadata>

#title()

Every slide, whatever its layout, is filled and configured the same way. This page collects that shared machinery once: how content reaches cells, how a single slide adjusts its layout, how a deck replaces a layout throughout, and how asset paths cross the package boundary. The #link("content.html")[content], #link("title.html")[title], #link("section.html")[section], and #link("image.html")[image] pages all rely on these rules.

= Filling cells

A slide accepts cell content in two distinct forms. Use positional content blocks (`[...][...]`) for a short grid whose traversal order is obvious, or use the named `cells:` dictionary to assign content by cell ID. Do not mix the two forms in one slide.

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

= Layout fields on a slide

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

= Reusing a layout

To replace a named layout throughout a deck, configure it once in `m.setup`:

```typ
#show: m.setup.with(layouts: (
  section: m.layouts.section(variant: "image-background", image: "chapter.jpg"),
))
```

To reuse a layout for selected slides, bind it with `m.slide.with`:

```typ
#let myslide = m.slide.with(
  layout: m.layouts.content(
    variant: "header-body",
  ),
)

#myslide(cells: (header: [== Slide title], body: [Slide content]))
```

See the #link("../api/layouts.html")[Layouts API] for all variants, cell IDs, and arguments.

= Asset paths <asset-paths>

An image or other asset named inside a layout argument crosses the package boundary: the layout function runs inside the installed Mosaic package, so a bare string like `"cover.webp"` is looked up in the package's own files rather than in your project, and the asset is not found. Wrap every asset path in Typst's `path()` so its location stays anchored to the calling document:

```typ
#m.slide(layout: "image", image: path("fig/gdp.png"))[== Growth since 1950]
```

This applies wherever a layout or component takes a path: the `image:` argument of the title, section, and image layouts, and the source of `m.components.image()` and `m.components.figure()`.

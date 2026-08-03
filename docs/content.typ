#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example

#set document(title: [Content])
#metadata((title: "Content")) <website-metadata>

#title()

Cells hold ordinary Typst content. This page collects the content you most often place inside them: images, the reusable `m.components` library, and math. None of these create slides or grids on their own; they are values you drop into a cell, a background, a foreground, or any native Typst composition.

= Filling cells

A slide accepts cell content in two distinct forms. Use positional content blocks (`[...][...]`) for a short grid whose traversal order is obvious, or use the named `content:` dictionary to assign content by cell ID. Do not mix the two forms in one slide.

== Positional content with `[][]`

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

== Named content with `content:`

Pass a dictionary to the named `content:` argument to associate each body with an explicit cell ID. Assignment then remains independent of the grid's traversal order. In the example below the same IDs also anchor the styling: one `show` rule per cell label tints each region, which is why the grid structure stays visible in the rendered frame.

#embedded-example(
  calepin.elements.gallery,
  "content/named-content",
  frames: 1,
  title: "Three bodies assigned explicitly by cell ID",
)

The cell ID connects all three layers: `m.grid.cell("body")` defines the cell, `content: (body: [...])` fills it, and `label("mosaic-cell-body")` styles it. Content-bearing cells are optional and resolve to empty content when omitted; unknown IDs are errors.

When a grid owns fixed content such as an image or logo, put it directly on the cell. Fixed cell content needs no positional body or `content:` entry:

```typ
#m.grid.cell("logo", content: image("logo.svg"))
```

= Images

You decide whether an image sits in a cell or on a
#link("furniture.html")[background or foreground plane]; Mosaic renders it
there, and image loading, fitting, figures, captions, and references remain native Typst. Full-slide photographic backgrounds are documented with the other plane material on the #link("furniture.html")[Furniture] page.

== Slide-sized images

Typst's standard `image()` works perfectly well in Mosaic and remains useful when its native sizing defaults are what you want. `m.components.image()` is a small convenience for the common slide case: it defaults both `width` and `height` to `100%` and `fit` to `"cover"`. Other native arguments, including `alt`, pass straight through. Use Typst's native `path()` for an image in your project so its location remains anchored to the calling document across the package boundary.

```typ
#m.components.image(
  path("photo.webp"),
  alt: "A mountain landscape",
)
```

== Scrims

A photograph rarely makes a good backdrop for text on its own: the picture is bright in some places and dark in others, so the same text is legible in one corner and lost in the next. A #emph[scrim] is the standard fix. It is a translucent layer painted over the picture and under the text, which compresses the photograph's tonal range and leaves the text with something predictable to sit on.

In Mosaic a scrim is an ordinary Typst paint. It accepts exactly what a `fill` accepts, and there is no separate vocabulary to learn:

```typ
#m.components.image(
  path("photo.webp"),
  scrim: black.transparentize(65%),
  alt: "A mountain landscape",
)
```

The paint's own transparency is the strength of the scrim. Typst spells that as the amount of transparency rather than the amount of coverage, so `black.transparentize(65%)` is black at 35% opacity: a light touch. `black.transparentize(20%)` is nearly opaque.

Three kinds of paint cover almost every case:

- A #emph[flat dark color] such as `black.transparentize(45%)` quiets the whole frame evenly. Pair it with a text color rule for a light-on-dark composition.
- A #emph[gradient] such as `gradient.linear(black.transparentize(100%), black.transparentize(10%), angle: 90deg)` darkens only the band the text occupies and releases the rest of the picture. This is the most common choice when the photograph is the point of the slide.
- A #emph[flat light color] such as `white.transparentize(25%)` washes the picture out instead, which keeps the deck's ordinary dark text readable and needs no color rule at all.

#embedded-example(
  calepin.elements.gallery,
  "blocks/image-scrim",
  frames: 4,
  title: "The same photograph with no scrim, a flat scrim, a gradient scrim, and a light scrim",
)

The scrim is a property of the picture, not of the cell around it, so it covers exactly the image area whether that area is a full-bleed background or an inset figure.

=== Where a scrim can be specified

One spelling covers every place an image can appear.

On `m.components.image()`, pass it as an argument, as above. That is the form to use for images in cells and for the `background` and `foreground` planes described on the #link("furniture.html")[Furniture] page.

In the `title`, `section`, and `image` layouts, the image is given as a specification dictionary, and `scrim` is one of its keys alongside `path`, `alt`, and `fit`:

```typ
#m.slide(layout: m.layouts.title(
  [Cities after dark],
  variant: "image-background",
  image: (
    path: path("cover.webp"),
    scrim: black.transparentize(45%),
    alt: "Coastal city lights at night",
  ),
))
```

A scrim changes the picture, never the text. Light-on-dark compositions still recolor the text through the cell's label, as the #link("structure.html")[Structure] page shows for the title and section layouts.

== Image fitting

The orange lines frame the full area of each cell. On the left, the white space between the frame and the picture is the cell's inset. The right cell shows more of the original picture because `contain` keeps the whole image visible, whereas `cover` crops it to fill the available image area.

#embedded-example(
  calepin.elements.gallery,
  "blocks/image-fit",
  frames: 1,
  title: "Image fit modes",
)

== Full-bleed cells

Cells have an `inset` by default. To make an image cover the full cell, including that content margin, set the inset to `0pt`. The defaults of `m.components.image()` then cover the complete cell. Declare that fixed image content and the zero inset directly with `cell`.

#embedded-example(
  calepin.elements.gallery,
  "blocks/full-bleed-image",
  frames: 1,
  title: "Full-bleed image cell",
)

== Figures

Native `figure` semantics, captions, numbering, and references continue to work inside cells.

#embedded-example(
  calepin.elements.gallery,
  "blocks/figure",
  frames: 1,
  title: "Semantic figure in a cell",
)

= Components

`m.components` provides reusable Typst content to place inside cells, or inside any native Typst composition. Each function has an independent example and gallery. One member, `m.components.progress()`, is documented with the deck infrastructure on the #link("furniture.html")[Furniture] page; it is ordinary content all the same and can sit in any cell.

== `frame()`

Wrap arbitrary content in a clipped semantic frame.

#embedded-example(
  calepin.elements.gallery,
  "blocks/component-frame",
  frames: 2,
  title: "components.frame()",
)

== `callout()`

Emphasize content with a semantic side stripe and optional title.

#embedded-example(
  calepin.elements.gallery,
  "blocks/component-callout",
  frames: 1,
  title: "components.callout()",
)

== `label()`

Create a compact inline label with configurable corners and text styling.

#embedded-example(
  calepin.elements.gallery,
  "blocks/component-label",
  frames: 1,
  title: "components.label()",
)

== `quote()`

Create a borderless quotation treatment with optional attribution.

#embedded-example(
  calepin.elements.gallery,
  "blocks/component-quote",
  frames: 1,
  title: "components.quote()",
)

== `divider()`

Separate content with an unlabeled or labeled horizontal divider.

#embedded-example(
  calepin.elements.gallery,
  "blocks/component-divider",
  frames: 1,
  title: "components.divider()",
)

= Math

Typst's native math notation works inside Mosaic slides. Incremental commands can then focus attention on one part of an equation at a time without changing its layout.

See #link("incremental.html")[Reveal or replace] for ways to reveal or annotate parts of an equation across frames.

== LaTeX

The #link("https://typst.app/universe/package/mitex/")[MiTeX package] converts LaTeX math source into Typst content. Import `mi` for inline equations and `mitex` for display equations, useful when reusing existing equations or collaborating with LaTeX authors.

#embedded-example(
  calepin.elements.gallery,
  "blocks/mitex",
  frames: 1,
  title: "Render LaTeX equations with MiTeX",
)

== Theorem

The #link("https://typst.app/universe/package/ctheorems/")[ctheorems package] provides numbered, referenceable theorem and proof environments. Define the environments once, install its `thmrules` show rule, and use them normally inside a Mosaic slide.

#embedded-example(
  calepin.elements.gallery,
  "blocks/theorem",
  frames: 1,
  title: "Typeset a theorem and proof",
)

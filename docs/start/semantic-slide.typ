#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": thumbnail-gallery
#import "/_includes/pdf-slideshow.typ": pdf-slideshow
#import "/_includes/site.typ": asset-url

#set document(title: [Semantic slide])
#metadata((title: "Semantic slide")) <website-metadata>

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

The #link("first-deck.html")[first deck] used `==` headings to separate content into standard slides. For a custom composition, write a slide with `m.slide` and name its cells by purpose, such as `header`, `body`, `footer`, `aside`, or `notes`. This is *semantic* structure: content and styling refer to what each cell means instead of where it appears.

Build a semantic slide in three separate layers: define its named grid, assign content to those names with `cells:`, and style the labeled cells with native Typst rules. The same slide grows through each step below.

= One named cell

Start with one named cell and pass it to `slide` as the layout.

```typ
#let single = m.grids.cell("main")

#m.slide(
  layout: single,
  cells: (main: [A semantic slide starts with one named cell.]),
)
```

#semantic-thumbnail(1, "A slide containing one named cell")

= Split the grid

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

= Nest splits and size tracks

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

= Add content

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

= Style the cells

Once the cells and content are in place, target each cell by its label. `m.surface` paints the cell, while `set align` positions its content.

```typ
#show label("mosaic-cell-main"): m.surface(fill: rgb("#7fa8cc"))
#show label("mosaic-cell-main"): set align(left + horizon)
#show label("mosaic-cell-notes"): m.surface(fill: rgb("#85b892"))
#show label("mosaic-cell-source"): m.surface(fill: rgb("#c9a75e"))
```

See #link("../appearance/styling.html#content-rules-and-surface-rules")[Styling cells] for styling details. #link("../slides/grids.html")[Grids and tracks] continues with grid sizes and built-in layouts.

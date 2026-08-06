#import "/_calepin/calepin.typ" as calepin_runtime
#import "/_calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": (
  example-source,
  thumbnail-gallery-items,
)

#set document(title: [Troubleshooting])
#metadata((
  title: "Troubleshooting",
  tags: ("help", "questions"),
)) <website-metadata>

#title()

= Where do slide margins go?

`setup` uses a zero page margin. Put content spacing on the cells with each cell's `inset`:

```typ
#show: m.setup

#let grid = m.grids.rows(
  m.grids.cell("a", inset: 1.5em),
  m.grids.columns(
    m.grids.cell("b", inset: 1.5em),
    m.grids.cell("c", inset: 1.5em),
  ),
)

#m.slide(layout: grid)[Top][Bottom left][Bottom right]
```

`inset` separates content from a cell's edges; adjacent cells each contribute their own inset. A grid `gutter` instead separates the cell surfaces and defaults to `0pt`.

= How do I change the slide aspect ratio?

Mosaic supports the two presentation aspect ratios built into Typst:

- `"16-9"` is the default widescreen format.
- `"4-3"` is the traditional format.

Choose one with the `paper` argument.

#example-source("faq/aspect-ratio-16-9")
#example-source("faq/aspect-ratio-4-3")

#thumbnail-gallery-items(
  calepin.elements.gallery,
  (
    (
      "/assets/examples/faq/aspect-ratio-16-9-1.svg",
      "A widescreen 16:9 slide",
      [16:9],
    ),
    (
      "/assets/examples/faq/aspect-ratio-4-3-1.svg",
      "A traditional 4:3 slide",
      [4:3],
    ),
  ),
)

= How do I inspect overflowing cells?

Mosaic records a warning when a cell's content is taller than the cell. Query those records with:

#calepin_runtime.chunk_from_raw_plain("sh", raw("  'query(<mosaic-overflow-warning>).map(it => it.value)' \\\n  --in slides.typ\n", block: true, lang: "sh"))

Each record identifies the slide, frame, cell, and measured height. Set `setup(overflow: "error")` to fail the compile instead, naming every overflowing cell with the same slide and frame numbers the query reports, or `setup(overflow: "off")` to turn the check off; see the
#link("../api/setup.html")[Setup API].

To make the content fit instead of reporting it, give the cell a `fit:` mode: `m.layouts.content(fit: "auto")` scales and reflows a body column into the available space, and `m.grids.cell(id, fit: ...)` does the same for a hand-built cell. Fitted cells never trigger the warning.

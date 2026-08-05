#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example, thumbnail-gallery

#set document(title: [Grids and tracks])
#metadata((title: "Grids and tracks")) <website-metadata>

#title()

Every `m.slide()` uses a layout. You can select a #link("layouts.html")[built-in layout] or pass a custom grid of named cells. The #link("../start/semantic-slide.html")[semantic slide tutorial] starts with one cell. This page shows how to arrange larger grids and size their tracks.

Each example below outlines its cells so the structure is visible. Those outlines are nothing but ordinary label rules, described in #link("../appearance/styling.html")[Styling cells]: they open every listing and are no part of the grid, which is the `#m.grids` tree alone.

= Grids with `h()` and `v()`

Describe a custom grid by splitting the available space. `m.grids.h` places cells side by side; `m.grids.v` stacks them. Each string is a cell ID. Import Mosaic under a short alias so native Typst `h()` and `v()` remain available:

```typ
#import "@local/mosaic:0.0.1" as m
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

Use `m.grids.v` for equal-height rows instead:

#embedded-example(
  calepin.elements.gallery,
  "structure/grid-rows",
  title: "Three equal-height rows",
  renderer: thumbnail-gallery,
  columns: 1,
  show-captions: false,
)

= Nesting

Any child of a split can be another grid, so a region can carry its own division. Here the outer `h` gives `a` the left half and stacks `b` and `c` on the right:

#embedded-example(
  calepin.elements.gallery,
  "structure/grid-nested",
  title: "One column beside a stacked pair",
  renderer: thumbnail-gallery,
  columns: 1,
  show-captions: false,
)

Two stacked `h` splits make a 2 x 2 arrangement:

#embedded-example(
  calepin.elements.gallery,
  "structure/grid-quadrants",
  title: "A two-by-two arrangement",
  renderer: thumbnail-gallery,
  columns: 1,
  show-captions: false,
)

Splits nest to any depth. Read a grid from the outside inward: choose the largest split first, then replace any child that needs another division with a nested `h` or `v`. Keep descriptive IDs and indentation so the tree stays visible in source:

#embedded-example(
  calepin.elements.gallery,
  "structure/grid-dashboard",
  title: "Three bands, the middle one divided twice",
  renderer: thumbnail-gallery,
  columns: 1,
  show-captions: false,
)

= Grid sizes (tracks)

By default, every direct child of `m.grids.h` or `m.grids.v` receives a `1fr` track. Wrap a child with `m.grids.t` when it needs another size:

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

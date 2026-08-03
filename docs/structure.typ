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

A slide's *layout* expresses its purpose and placement contract: `content`,
`title`, or `section`. The layout resolves to a low-level *grid* of cells.
Override it directly when one slide needs a custom shape. Either way, fill cells
with content and style them separately with native Typst rules; see
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

= Layouts

A layout is a complete deferred page-placement contract with one of three
standard names: `content`, `title`, or `section`. `layout: auto` selects the
configured content layout. A string selects the matching `setup(layouts:)`
entry; a direct `m.layouts.*` value carries its own name; and a hand-built grid
is treated as content. The selected layout determines default numbering and
section counting.

Override one named layout deck-wide with a partial dictionary:

```typ
#show: m.setup.with(layouts: (
  section: m.layouts.section(variant: "image-background", image: "chapter.jpg"),
))
```

For a reusable per-slide override, bind `layout:` with `m.slide.with`:

```typ
#set page(fill: rgb("#111827"))
#set text(fill: rgb("#f3f4f6"))

#let myslide = m.slide.with(
  layout: m.layouts.content(
    variant: "header-body",
  ),
)

#myslide(content: (header: [== Slide title], body: [Slide content]))
```

Keep structure and drawn decoration on the layout, slide behavior on `m.slide`,
and appearance in native `set` and `show` rules. Every layout cell has a
`<mosaic-cell-ID>` label; see #link("appearance.html")[Appearance]. Exact
variants, cell IDs, and arguments live in the
#link("api/layouts.html")[Layouts API].

== `content()`

Use `content()` for ordinary slides, optionally with a header, footer, or
multiple columns. Mosaic uses the active content layout for `==` heading
slides as well.

#embedded-example(
  calepin.elements.gallery,
  "structure/content-layout-full",
  frames: 1,
  title: "A slide with header, body, and footer cells",
  renderer: thumbnail-gallery,
)

A reusable footer is ordinary inherited content for the layout's `footer` cell,
not a global overlay. Configure it once with `setup(content:)`; see
#link("furniture.html#default-footer-content")[Default footer content].

Style its header, body, and footer labels with native rules:

#embedded-example(
  calepin.elements.gallery,
  "structure/content-layout-inverted",
  frames: 1,
  title: "A content slide with an inverted header and footer",
  renderer: thumbnail-gallery,
)

Bundle reusable cell rules in a transformer so every content slide shares them:

#embedded-example(
  calepin.elements.gallery,
  "structure/content-layout-custom",
  frames: 2,
  title: "Slides made with a reusable custom look",
  renderer: thumbnail-gallery,
)

== `title()`

Use `layout: "title"` for an opening slide. Its configured `title()` layout
inherits setup metadata (subtitle, authors, and date), so the surrounding
`m.slide(layout: "title")` needs no body. The nine frames below move from metadata-heavy to image-first: inline
academic metadata with affiliations and ORCID, a left-aligned variant with
foreground marks placed over the layout, a centered stack, a solid accent
spine, and the image variants (`image-right`, `image-left`, `image-top`,
`image-bottom`, `image-background`). In the final frame the image itself
carries the contrast: `darken:` dims the photograph and a scoped rule on the
`<mosaic-cell-title>` label switches that one slide to light text.

#embedded-example(
  calepin.elements.gallery,
  "structure/title-layout",
  frames: 9,
  title: "Nine structural title variants with inline academic metadata and images",
  renderer: thumbnail-gallery,
)

== `section()`

Use `layout: "section"` for a section divider. Its configured `section()` layout
may include a subtitle, number, or image. The frames below grow the same divider one argument at a time: plain,
numbered, then each image placement. The last frame repeats the pattern from
the title layout, pairing a darkened `image-background` with white text
through the `<mosaic-cell-section>` label, scoped to that slide alone.

#embedded-example(
  calepin.elements.gallery,
  "structure/section-layout",
  frames: 7,
  title: "Section divider variants",
  renderer: thumbnail-gallery,
)

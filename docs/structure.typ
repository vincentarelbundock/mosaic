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

Every `m.slide()` uses a layout. You can select a built-in layout or pass a custom grid of named cells. The #link("basics.html#semantic-slide")[semantic slide tutorial] starts with one cell. This page shows how to arrange larger grids and use the built-in layouts.

= Grids with `h()` and `v()`

Describe a custom grid by splitting the available space. `m.grid.h` places cells side by side; `m.grid.v` stacks them. Each string is a cell ID. Import Mosaic under a short alias so native Typst `h()` and `v()` remain available:

```typ
#import "@local/mosaic:0.0.1" as m
```

Three strings produce three equal-width columns:

```typ m.grid.h("a", "b", "c") ```

#grid-thumbnail(
  "/assets/examples/structure/grid-splits-1.svg",
  "Three equal columns",
)

Use `m.grid.v` for equal-height rows instead:

```typ m.grid.v("a", "b", "c") ```

#grid-thumbnail(
  "/assets/examples/structure/grid-splits-2.svg",
  "Three equal rows",
)

Any child can be another grid. Here the outer horizontal split gives `a` the left half, while a nested vertical split stacks `b` and `c` on the right:

```typ m.grid.h("a", m.grid.v("b", "c")) ```

#grid-thumbnail(
  "/assets/examples/structure/grid-splits-3.svg",
  "One column beside two stacked cells",
)

Read a grid from the outside inward: choose the largest split first, then replace any child that needs another division with a nested `h` or `v`. Keep descriptive IDs and indentation so the tree remains visible in source.

= Grid sizes (tracks)

By default, every direct child of `m.grid.h` or `m.grid.v` receives a `1fr` track. Wrap a child with `m.grid.t` when it needs another size. Here `a` receives two thirds of the width and `b` one third:

```typ m.grid.h(m.grid.t(2fr, "a"), "b") ```

#grid-thumbnail(
  "/assets/examples/structure/grid-tracks-1.svg",
  "A two-to-one horizontal split",
)

Tracks accept native `auto`, fixed lengths, percentages, and `fr` values. The
#link("api/grid.html")[Grid API] lists exact accepted forms and diagnostics.

= Layouts

Start with Mosaic's ready-made content layout:

```typ
#m.slide(layout: "content")[Slide content]
```

The other recognized names are `"title"` and `"section"`. Because `"content"` is the default, you can usually omit it. Pass `m.layouts.*` to build a layout from scratch, or one of the custom grids described above.

== Layout fields on a slide

Any named argument `slide` does not recognize is a field of the selected layout. So a single slide can change one aspect of the configured layout without restating it:

```typ
#m.slide(layout: "title", variant: "academic")
#m.slide(layout: "section", number: [03])[Methods]
#m.slide(columns: 2)[Left column][Right column]
```

This differs from passing `m.layouts.title(variant: "academic")`, which *replaces* the configured layout. Named arguments *refine* it: whatever the theme or `m.setup` set for that layout, such as an accent color or a background image, survives. Only the fields you name change.

The two forms are mutually exclusive on one slide. With an explicit `m.layouts.*` value, pass the fields to that constructor instead, because that is where they belong:

```typ
// Refines the configured title layout.
#m.slide(layout: "title", variant: "academic")

// Replaces it; the fields go to the constructor.
#m.slide(layout: m.layouts.title(variant: "academic"))
```

Field names are checked against the selected layout, so `m.slide(layout: "title", columns: 2)` fails at compile time rather than being silently ignored. Fields also require a layout chosen by name: if `m.setup` configures that layout as a raw grid rather than an `m.layouts.*` value, there are no fields to refine and Mosaic says so. The #link("api/layouts.html")[Layouts API] lists the fields each layout accepts.

== `content()`

Use `m.layouts.content()` to choose a structure with a header, footer, or multiple columns. Mosaic also uses the active content layout for `==` slides.

#embedded-example(
  calepin.elements.gallery,
  "structure/content-layout-full",
  frames: 1,
  title: "A slide with header, body, and footer cells",
  renderer: thumbnail-gallery,
)

See #link("furniture.html#default-footer-content")[Furniture] for recurring footer content and #link("appearance.html#styling-cells")[Appearance] for cell styling.

== `title()`

Use `layout: "title"` for an opening slide. Declare the deck's title information once in `m.setup`, then create the slide where you want it:

```typ
#let authors = (m.layouts.author("Ada Lovelace"),)

#show: m.setup.with(
  title: [Reliable systems],
  subtitle: [One source of truth],
  authors: authors,
  date: [2026],
)

#m.slide(layout: "title")
```

#embedded-example(
  calepin.elements.gallery,
  "appearance/setup-deck",
  frames: 2,
  title: "Title information shared across a deck",
)

To change one field for one slide, name it on `slide`: `m.slide(layout: "title", variant: "academic")`. Pass `m.layouts.title(...)` directly when the slide needs a title layout built from scratch rather than a refinement of the configured one. The gallery moves from text-based titles to layouts that place an image beside, above, below, or behind the title.

#embedded-example(
  calepin.elements.gallery,
  "structure/title-layout",
  frames: 9,
  title: "Nine structural title variants with inline academic metadata and images",
  renderer: thumbnail-gallery,
)

== `section()`

Use `layout: "section"` for a section divider. Its configured `section()` layout may include a subtitle, number, or image. The frames below grow the same divider one argument at a time: plain, numbered, then each image placement. The last frame repeats the pattern from the title layout, pairing an `image-background` carrying a #link("content.html#scrims")[scrim] with white text through the `<mosaic-cell-section>` label, scoped to that slide alone.

#embedded-example(
  calepin.elements.gallery,
  "structure/section-layout",
  frames: 7,
  title: "Section divider variants",
  renderer: thumbnail-gallery,
)

== Reusing a layout

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

#myslide(content: (header: [== Slide title], body: [Slide content]))
```

See the #link("api/layouts.html")[Layouts API] for all variants, cell IDs, and arguments.

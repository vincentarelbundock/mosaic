#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example, thumbnail-gallery
#import "/_includes/pdf-slideshow.typ": pdf-slideshow
#import "/diagrams/grid-anatomy.typ": diagram as grid-anatomy
#import "/diagrams/slide-planes.typ": diagram as slide-planes

#set document(title: [Basics])
#metadata((title: "Basics")) <website-metadata>

// One step of the canonical semantic-slide example, shown through the same
// PDF slideshow treatment as every other embedded example. The preview image
// is that step's frame; the dialog pages through the whole walkthrough.
#let semantic-frames = 5
#let semantic-thumbnail(frame, alt) = {
  if sys.inputs.at("calepin-target", default: "paged") == "html" {
    pdf-slideshow(
      "assets/examples/basics/semantic-slide.pdf",
      "assets/examples/basics/semantic-slide-" + str(frame) + ".svg",
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

= First slideshow

First, import Mosaic and apply its setup rule:

```typ
#import "@local/mosaic:0.0.1" as m
#show: m.setup
```

`m.setup` applies the page and theme defaults and turns headings and explicit `m.slide` commands into slides.

After `#show: m.setup`, every `==` starts a *content slide*: the heading becomes the title and the text that follows becomes its content. A single `=` starts an unnumbered *section slide* with a larger, centered title.

The example below is a complete deck. It declares its title and subtitle once in `m.setup`, opens with the built-in `title` layout, groups the rest under two section slides, and fills every content slide with ordinary Typst content.

#embedded-example(
  calepin.elements.gallery,
  "getting-started/first-slideshow",
  frames: 5,
  title: "A deck of content slides with an image title slide and two sections",
)

= Concepts

On this website, we will refer to the different components of a slide deck in these terms:

- *Slide*: one unit of a presentation.
- *Deck*: a sequence of slides.
- *Cell*: a named area that holds content.
- *Grid*: named cells arranged with horizontal and vertical splits.
- *Split*: a horizontal or vertical division between cells.
- *Inset*: space between a cell's edge and its content.
- *Background*: content drawn behind the content grid across the full slide.
- *Foreground*: content drawn over the content grid across the full slide.
- *Layout*: a ready-made slide arrangement with a grid and, when needed, built-in content or decoration.
- *Theme*: a coordinated set of colors, text styles, and layouts.

= Anatomy of a slide deck

#html.frame(grid-anatomy)\
#v(1em)

The grid is sandwiched between two full-slide planes. The *background* plane is painted behind the cells. It typically holds a full-slide image, a color wash, or a watermark. The *foreground* plane is painted over the cells. It typically holds a slide number, a logo, or a progress indicator. Neither plane takes space away from the grid.

#v(1em)\
#html.frame(slide-planes)
#v(1em)\

A *layout* is a ready-made slide design for a familiar slide kind such as a title or section. A layout provides a structural grid and may supply fixed content or limited structural decoration for that design. Each layout offers several named *variants*.

Each of the elements of a slide is a native Typst layer, and every cell, the foreground, and the background all carry a Typst-native *label*: `<mosaic-cell-ID>`, `<mosaic-foreground>`, and `<mosaic-background>`. This means that we can style each element of the stack using ordinary Typst `show` and `set` rules. See the #link("appearance.html")[Appearance Page] for a detailed tutorial.

= Semantic slide

The first slideshow used `==` headings to separate content into standard slides. For a custom composition, write a slide with `m.slide` and name its regions by purpose, such as `header`, `body`, `footer`, `aside`, or `notes`. This is *semantic* structure: content and styling refer to what each region means instead of where it appears.

Build a semantic slide in three separate layers: define its named grid, assign content to those names with `content:`, and style the labeled cells with native Typst rules. The same canonical composition grows through each step below.

== One named cell

Start with one named cell and pass it to `slide` as the layout.

```typ
#let single = m.grid.cell("main")

#m.slide(
  layout: single,
  content: (main: [A semantic slide starts with one named cell.]),
)
```

#semantic-thumbnail(1, "A slide containing one named cell")

== Split the grid

`m.grid.h` places cells side by side. Each key in `content:` matches one cell ID.

```typ
#let columns = m.grid.h("main", "aside")

#m.slide(
  layout: columns,
  content: (
    main: [The main argument],
    aside: [Supporting evidence],
  ),
)
```

#semantic-thumbnail(2, "The canonical slide split into two equal columns")

== Nest splits and size tracks

Splits nest directly: `v` stacks the sidebar cells, `t` assigns their proportions, and `h` combines the sidebar with the main region.

```typ
#let composition = m.grid.h(
  m.grid.t(2fr, "main"),
  m.grid.t(1fr, m.grid.v(
    m.grid.t(2fr, "notes"),
    m.grid.t(1fr, "source"),
  )),
)

#m.slide(
  layout: composition,
  content: (
    main: [The main argument],
    notes: [Two parts notes],
    source: [One part source],
  ),
)
```

#semantic-thumbnail(3, "A two-thirds main cell beside a vertically split sidebar")

== Add content

The grid remains unchanged while the `content:` dictionary receives ordinary Typst markup: headings, lists, emphasis, figures, equations, or any custom content.

```typ
#m.slide(
  layout: composition,
  content: (
    main: [
      == Composition

      - Name every region.
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

#semantic-thumbnail(4, "The canonical grid filled with semantic Typst content")

== Style the cells

Once the cells and content are in place, target each cell by its label. `m.surface` paints the cell, while `set align` positions its content.

```typ
#show label("mosaic-cell-main"): m.surface(fill: rgb("#7fa8cc"))
#show label("mosaic-cell-main"): set align(left + horizon)
#show label("mosaic-cell-notes"): m.surface(fill: rgb("#85b892"))
#show label("mosaic-cell-source"): m.surface(fill: rgb("#c9a75e"))
```

See #link("appearance.html#content-rules-and-surface-rules")[Appearance] for styling details. The #link("structure.html")[Structure] page continues with grid sizes and built-in layouts.

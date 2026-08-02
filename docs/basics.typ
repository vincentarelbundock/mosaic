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

= Anatomy of a slide deck

A Mosaic *deck* is a sequence of *slides*. Each slide arranges its content on
a *grid*. A grid is built from horizontal and vertical *splits*. The smallest
parts of a grid are its named *cells*. Each cell receives one block of
content. The *inset* is the internal space between a cell's edge and its
content.

#html.frame(grid-anatomy)

The grid is sandwiched between two full-slide *planes*. The *background*
plane is painted behind the cells. It typically holds a full-slide image, a
color wash, or a watermark. The *foreground* plane is painted over the cells.
It typically holds a slide number, a logo, or a progress indicator. Neither
plane takes space away from the grid.

#html.frame(slide-planes)

A *layout* is a ready-made slide design for a familiar slide kind such as
a title or section. A layout provides a structural grid and may supply fixed
content or limited structural decoration for that design. Cell appearance and
full-slide planes remain ordinary Typst rules and explicit slide arguments.
Each layout offers several named *variants*.

A slide can reveal its content in *steps*. Each step renders as one *frame*.
Each frame is one page in the PDF. Page and text color are ordinary Typst
settings; built-in colored layout decoration takes an explicit `accent:`.

Each of these elements is a native Typst layer, and every cell carries a
native *label*, `<mosaic-cell-ID>`, so ordinary `show` and `set` rules style
the whole stack; #link("appearance.html")[Appearance] presents the styling
model.

= First slideshow

Mosaic turns ordinary Typst headings into slides. This keeps a first deck
short, readable, and easy to edit.

After `#show: m.setup`, every `==` writes a *heading slide*: the heading
becomes the title and the text that follows becomes its content. Every single
`=` writes an unnumbered *section slide*, whose title is larger and centered
by default. Together they give a lightweight hierarchy with no special slide
commands.

The example below is a complete deck. It opens with a title slide built from
the `image-background` title layout, with the title anchored to the top-right
corner; groups the rest under two section slides; and fills every heading
slide with ordinary Typst content. The code block is the exact source for the
rendered slideshow beneath it.

#embedded-example(
  calepin.elements.gallery,
  "getting-started/first-slideshow",
  frames: 5,
  title: "A deck of heading slides with an image title slide and two sections",
)

= Semantic slide

Build a semantic slide in three separate layers: define its named grid, assign
content to those names with `content:`, and style the labeled cells with
native Typst rules. The same canonical composition grows through each step
below.

The styling layer comes first here. The rules below run once, ahead of the
first slide, and tint each named cell used in this walkthrough. That is why
every thumbnail shows its grid structure in color: the styles are global
`show` rules on cell labels, not arguments to `slide` or `grid`. How
`m.surface` and `set` rules divide that work is explained in
#link("appearance.html#content-rules-and-surface-rules")[Appearance: content rules and surface rules].

```typ
#show label("mosaic-cell-main"): m.surface(fill: rgb("#7fa8cc"))
#show label("mosaic-cell-main"): set align(left + horizon)
#show label("mosaic-cell-aside"): m.surface(fill: rgb("#c9a75e"))
#show label("mosaic-cell-aside"): set align(left + horizon)
#show label("mosaic-cell-notes"): m.surface(fill: rgb("#85b892"))
#show label("mosaic-cell-notes"): set align(left + horizon)
#show label("mosaic-cell-source"): m.surface(fill: rgb("#c9a75e"))
#show label("mosaic-cell-source"): set align(left + horizon)
```

== One named cell

Start with a structural value and pass it to `slide`. Keeping the grid outside
the call gives it a name, makes it reusable, and leaves the slide invocation
focused on content assignment.

```typ
#let single = m.grid.cell("main")

#m.slide(
  grid: single,
  content: (main: [A semantic slide starts with one named cell.]),
)
```

#semantic-thumbnail(1, "A slide containing one named cell")

== Split the grid

`m.grid.h` places cells side by side. Assign the split to `columns` before
passing it to the slide; each dictionary key matches one cell ID.

```typ
#let columns = m.grid.h("main", "aside")

#m.slide(
  grid: columns,
  content: (
    main: [The main argument],
    aside: [Supporting evidence],
  ),
)
```

#semantic-thumbnail(2, "The canonical slide split into two equal columns")

== Nest splits and size tracks

Splits nest directly: `v` stacks the sidebar cells, `t` assigns their
proportions, and `h` combines the nested sidebar with the main region, all in
one declaration. The finished grid still lives outside `slide`.

```typ
#let composition = m.grid.h(
  m.grid.t(2fr, "main"),
  m.grid.t(1fr, m.grid.v(
    m.grid.t(2fr, "notes"),
    m.grid.t(1fr, "source"),
  )),
)

#m.slide(
  grid: composition,
  content: (
    main: [The main argument],
    notes: [Two parts notes],
    source: [One part source],
  ),
)
```

#semantic-thumbnail(3, "A two-thirds main cell beside a vertically split sidebar")

== Add content

The grid remains unchanged while the `content:` dictionary receives ordinary
Typst markup: headings, lists, emphasis, figures, equations, or any custom
content.

```typ
#m.slide(
  grid: composition,
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

== Built-in layouts

Built-in layouts are ready-made semantic grids. Assign a layout to a value,
then pass that value to `slide` just like the custom grids above. Here the
default layout supplies a familiar header-and-body structure:

```typ
#let default-layout = m.layouts.default(variant: "header-body")
#m.slide(grid: default-layout, content: (
  header: [== Default layout],
  body: [A familiar header-and-body structure.],
))
```

#semantic-thumbnail(5, "The built-in header-and-body default layout")

`m.layouts.title` and `m.layouts.section` work the same way for opening and
divider slides; #link("structure.html")[Structure] walks through all three
layouts and their variants.

Continue with #link("structure.html")[Structure] for the complete grid and
layout model, #link("content.html")[Content] for material placed in cells, and
#link("appearance.html")[Appearance] for reusable native styling.

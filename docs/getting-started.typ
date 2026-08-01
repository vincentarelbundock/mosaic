#import "/.calepin/calepin.typ" as calepin
#import "/_includes/tutorial-gallery.typ": slideshow, verbatim-example
#import "/diagrams/grid-anatomy.typ": diagram as grid-anatomy
#import "/diagrams/slide-planes.typ": diagram as slide-planes

#set document(title: [Basics])
#metadata((title: "Basics")) <website-metadata>

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
a title, section, image, or table. A layout provides a grid. It can also
style cells and place content on the planes. Each layout offers several
named *variants*.

A slide can reveal its content in *steps*. Each step renders as one *frame*.
Each frame is one page in the PDF. A *scheme* assigns colors to semantic
*roles*, such as `accent` and `text`, across the whole deck.

= First slideshow

Mosaic can turn ordinary Typst headings into slides. This keeps a first deck
short, readable, and easy to edit.

After `#show: m.setup`, every `==` signals the start of a new slide. The
heading becomes the slide title, and the text that follows becomes its
content.

The example below is a complete four-slide deck. It opens with one title
slide built from the `image-background` title layout, with the title
anchored to the top-right corner. Every slide after that is just a `==`
heading followed by normal Typst content. The code block is the exact source
for the rendered slideshow beneath it.

#verbatim-example("basic/single.typ")

#slideshow(
  calepin.elements.gallery,
  "basic/single",
  4,
  "A minimal heading-driven deck with an image title slide",
)

= Sections

A single `=` starts an unnumbered section slide. A double `==` starts a regular
slide. Section titles are larger and centered by default. Together, they
provide a lightweight hierarchy without adding any special slide commands.

#verbatim-example("basic/sections.typ")

#slideshow(
  calepin.elements.gallery,
  "basic/sections",
  5,
  "Two sections and three slides",
)

= Global style

`m.setup` applies presentation-oriented page, typography, heading,
caption, list, and cell-inset defaults. Customize native elements with
ordinary Typst rules after setup:

The default typeface is Inter, with Typst's embedded Libertinus Serif as a
guaranteed fallback. Body text is 28pt, titles are 2em, slide
headings are 1.4em semibold, captions are 0.72em, and supporting text is 0.55em.
Overflowing content is shown rather than shrunk. Bulleted, numbered, and
term-list items use 0.5em spacing.

```typ
#show: m.setup

#set text(font: "Libertinus Serif", size: 30pt)
#show heading.where(depth: 2): set text(
  size: 1.3em,
  weight: "bold",
)
#show figure.caption: set text(size: 0.72em, fill: gray)
```

= Semantic slide

The simplest semantic grid is `layouts.default(variant: "body")`. Its one
body cell fills the slide.

```typ
#m.slide(grid: m.layouts.default(variant: "body"))[
  #lorem(20)
]
```

Use heading-driven slides for ordinary narrative flow and layout grids for
familiar structures such as title slides, images, and tables. Pass each
layout grid to `m.slide`. Both forms mix freely in one deck.

```typ
#show: m.setup.with(
  colors: m.color.scheme("dark") + (
    accent: rgb("#e69f00"),
  ),
  features: (
    slide-number: true,
    progress: true,
  ),
)

#m.slide(grid: m.layouts.default(variant: "body"))[
  #lorem(20)
]

#m.slide(grid: m.layouts.title([Research result], subtitle: [A short deck]))

#m.slide(grid: m.layouts.image(
  variant: "figure",
  path: path("/docs/assets/images/dog.webp"),
  alt: "Dog",
))
```

See the #link("colors.html")[Colors guide] for complete light and dark schemes,
semantic role overrides, and categorical palettes.

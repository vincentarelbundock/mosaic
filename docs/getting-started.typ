#import "/.calepin/calepin.typ" as calepin
#import "/_includes/tutorial-gallery.typ": (
  slideshow,
  thumbnail-gallery-items,
  verbatim-example,
)

#set document(title: [Basics])
#metadata((title: "Basics")) <website-metadata>

#title()

Mosaic can turn ordinary Typst headings into slides. This keeps a first deck
short, readable, and easy to edit.

= First slideshow

After `#show: m.setup`, every `==` signals the start of a new slide. The
heading becomes the slide title, and the text that follows becomes its
content.

The example below is a complete three-slide deck. There are no individual
`slide` calls: write a `==` heading and continue with normal Typst. The code
block is the exact source for the rendered slideshow beneath it.

#verbatim-example("basic/single.typ")

#slideshow(
  calepin.elements.gallery,
  "basic/single",
  3,
  "A minimal heading-driven deck",
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

The default typeface list starts with Inter and ends with Typst's embedded
Libertinus Serif as a guaranteed terminal family. Typst's last-resort glyph
fallback also remains enabled. Body text is 28pt, titles are 2em, slide
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

= Slide aspect ratio

Mosaic supports the two presentation aspect ratios built into Typst:

- `"16-9"` is the default widescreen format.
- `"4-3"` is the traditional format.

Choose one with the `paper` argument.

#verbatim-example("basic/aspect-16-9.typ")
#verbatim-example("basic/aspect-4-3.typ")

#thumbnail-gallery-items(
  calepin.elements.gallery,
  (
    (
      "/assets/tutorials/basic/aspect-16-9-1.svg",
      "A widescreen 16:9 slide",
      [16:9],
    ),
    (
      "/assets/tutorials/basic/aspect-4-3-1.svg",
      "A traditional 4:3 slide",
      [4:3],
    ),
  ),
)

= Semantic slide

The simplest semantic grid is `templates.default(variant: "body")`. Its one
body cell fills the slide.

```typ
#m.slide(grid: m.templates.default(variant: "body"))[
  #lorem(20)
]
```

Use heading-driven slides for ordinary narrative flow and template grids for
familiar structures such as title pages, images, and tables. Pass each
template grid to `m.slide`; both
forms compile through the same deck pipeline.

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

#m.slide(grid: m.templates.default(variant: "body"))[
  #lorem(20)
]

#m.slide(grid: m.templates.title(subtitle: [A short deck]))[Research result]

#m.slide(grid: m.templates.image(
  variant: "figure",
  path: path("/docs/assets/images/dog.webp"),
  alt: "Dog",
))
```

See the #link("colors.html")[Colors guide] for complete light and dark schemes,
semantic role overrides, and categorical palettes.

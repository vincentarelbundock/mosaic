#import "/.calepin/calepin.typ" as calepin
#import "/_includes/tutorial-gallery.typ": (
  thumbnail-gallery,
  verbatim-example,
)

#set document(title: [Layouts])
#metadata((title: "Layouts")) <website-metadata>

#title()

The #link("getting-started.html")[Basics] guide introduced layouts as
ready-made grids for familiar slide structures. Choose a function and, when
available, a `variant`; then pass the result to `m.slide(grid: ...)`.
Supply the slide's main content in `[...]` blocks after the call. The galleries
below are compiled from the source displayed beside them.

The common pattern is to create a slide function that combines the grid with
its slide options, then reuse that function with different content:

```typ
#let myslide = m.slide.with(
  grid: m.layouts.default(variant: "header-body"),
  colors: m.color.scheme("dark"),
  numbered: true,
)

#myslide[== Slide title][Slide content]
```

This keeps structural options on the layout constructor; slide behavior such
as `colors`, `background`, `foreground`, and `numbered` on `m.slide.with`; and
individual slide calls focused on content.

= `default()`

Creates a grid with one of four named cell structures. `variant` accepts `"body"`,
`"header-body"`, `"body-footer"`, or `"header-body-footer"`; the complete
`"header-body-footer"` structure is the default. `columns` controls the number
of body cells, while `tracks` optionally sets their relative or fixed widths.
Mosaic uses `"header-body"` for automatic slides created with `==`.

For an explicit titled slide, write `==` in the header block. This keeps normal
Typst heading styling and registers the heading with outlines.

Set `progress` to `"1/1"`, `"1"`, `"circle"`, or `"line"` to add progress on the
slide foreground, or leave it as `none`. The indicator follows slide-local
colors. When the layout includes a footer, it also follows the footer's
insets, text size, explicit text fill, and inverted color treatment.

== Cells

The variant determines which named cells are present and therefore the order
of the slide's content blocks:

- `variant: "body"` expects `[body]`.
- `variant: "header-body"` expects `[header][body]`.
- `variant: "body-footer"` expects `[body][footer]`.
- The default `variant: "header-body-footer"` expects `[header][body][footer]`.

This example shows the complete three-cell structure:

#verbatim-example("layouts/default-full.typ")
#thumbnail-gallery(
  calepin.elements.gallery,
  "layouts/default-full",
  1,
  "A slide with header, body, and footer cells",
)

The header remains content-sized:

#verbatim-example("layouts/default-header.typ")
#thumbnail-gallery(
  calepin.elements.gallery,
  "layouts/default-header",
  1,
  "A slide with a header and one body cell",
)

== Columns

`columns` divides the body into equal columns by default. Set `tracks` to an
array with one native Typst track size per column when their widths should
differ. Supply one body block per column, after any header block.

#verbatim-example("layouts/default-columns.typ")
#thumbnail-gallery(
  calepin.elements.gallery,
  "layouts/default-columns",
  1,
  "A slide with a header and three weighted body columns",
)

== Style

Use `fill`, `text`, `align`, and `inset` dictionaries to style cells by name.
Omitted cell keys keep the setup defaults. List cells in `inverted` to fill
the header, footer, or both with the inherited scheme's `text` color and render
their content with `inverse-text`; for example, use
`inverted: ("footer",)` to invert only the footer. The body retains the normal
`canvas` and `text` roles. Explicit per-cell `fill` and `text` values override
those inherited defaults. Fills accept native Typst values, including
gradients. Use `background` with explicit native content such as `image(...)`
for a cell background:

This example selects both surrounding cells:

#verbatim-example("layouts/default-inverted.typ")
#thumbnail-gallery(
  calepin.elements.gallery,
  "layouts/default-inverted",
  1,
  "A default slide with an inverted header and footer",
)

Per-cell dictionaries remain available for independent visual styling:

#verbatim-example("layouts/default-images.typ")
#thumbnail-gallery(
  calepin.elements.gallery,
  "layouts/default-images",
  1,
  "A slide with a solid header, darkened body image, and gradient footer",
)

== Wrapping

Header and footer cells keep their normal one-line height when possible.
Because their tracks are content-sized, wrapped text expands their fills
vertically and leaves the remaining height to the body.

#verbatim-example("layouts/default-wrapping.typ")
#thumbnail-gallery(
  calepin.elements.gallery,
  "layouts/default-wrapping",
  1,
  "A slide whose filled header and footer expand onto multiple lines",
)

== Reusable style

Use Typst's native `.with(...)` to save a configured layout function. The
resulting `custom` shortcut can create as many grids as needed while each slide
continues to supply its own header, body, and footer.

#verbatim-example("layouts/default-custom.typ")
#thumbnail-gallery(
  calepin.elements.gallery,
  "layouts/default-custom",
  2,
  "Slides made with the reusable custom layout",
)

= `author()`

Creates a validated author object shared by every title variant:

```typst
#let ada = mosaic.author(
  [Ada Lovelace],
  affiliations: ((id: "udem", name: [Université de Montréal]),),
  email: "ada@example.org",
  orcid: "0000-0001-2345-6789",
  corresponding: true,
)
```

`name` is required. `affiliations` is an array of dictionaries with a stable,
non-empty string `id` and visible `name`. `email` and `orcid` are independent
optional fields; email syntax and the ORCID checksum are validated. When an
ORCID is present, Mosaic places a linked ORCID icon immediately after the
author's name. A corresponding author must provide an email or ORCID. All title
commands accept only arrays of objects produced by `author()` and revalidate
them when the command is resolved.

= `title()`

Creates a complete opening-slide grid. The title text is the first positional
argument, and the layout supplies every cell's content, so the surrounding
`m.slide` call consumes no content blocks. The default
`"left-aligned"` variant is text-only. The complete set describes the rendered
structure: `"academic"`, `"left-aligned"`, `"centered-stack"`,
`"accent-block"`, `"image-left"`, `"image-right"`, `"image-top"`,
`"image-bottom"`, and `"image-background"`.

Every variant accepts `subtitle`, `authors`, and `date`. The ordinary text,
accent, and image variants show author names and affiliations but omit contact
details. They compose these values in one title cell as two masses: the title
and subtitle sit tight together, then the metadata compresses to a byline
plus one fine-print line joining affiliations and date. A short
accent-colored rule marks the break between the two masses on the text
variants; the image variants omit it by default so their looks stay
photographic. Set `rule: true` or `rule: false` to override either default.
`centered-stack` centers that
complete stack; every other text variant anchors it to the bottom edge.
`accent-block` runs a narrow accent-colored spine along the leading edge. The
default is `left-aligned`.

The `academic` structure requires a non-empty `authors` array of `author()`
objects. Mosaic de-duplicates affiliations by `id`, numbers them in first-seen
order, adds superscripts to author names, and generates one inline affiliation
legend. Reusing an ID with a different name is an error. A corresponding author
receives an asterisk. ORCID is represented only by the linked icon beside the
author's name.
The title and subtitle share the `title` cell. The `academic` variant
additionally uses an `authors` byline cell and a single fine-print `details`
cell that shows the affiliation legend on one line, then contact emails and
the date on a second line.
Absent optional cells are omitted.

Title grids suppress the presentation's global logo. Add a logo, event label,
or other decoration explicitly with the title slide's `foreground` argument;
an event may instead be written directly into `subtitle`:

```typ
#m.slide(
  grid: m.layouts.title(
    [Models, evidence, and public decisions],
    subtitle: [Annual Research Lecture · Montréal, 2027],
  ),
  foreground: [
    #place(top + left)[#text(size: 10pt, weight: "bold")[RESEARCH LAB]]
    #place(top + right)[#image("logo.svg", width: 18mm)]
  ],
)
```

The five image variants require `image`, either native content, a non-empty path
string, or a dictionary with `path` plus optional `alt` and `fit`. For custom
image sizing or composition, pass native content instead of a path:

- `image-left` and `image-right` place a full-height image beside the title stack.
- `image-top` and `image-bottom` place a full-width image above or below the title stack.
- `image-background` covers the canvas with the image and positions the title
  stack over it with `align`. Combine horizontal and vertical alignment, such
  as `align: top + left` for a top-left title or `center + horizon` for a
  centered title. The stack keeps the scheme's ordinary `text` color, so the
  image must carry the contrast: pass a pre-adjusted image such as
  `m.image(path(...), darken: 45%)` and override the `title` cell's text fill
  through `cell-styles` for light-on-dark compositions.

For the four directional variants, `tracks` accepts `auto` or two native Typst
track sizes in visual order. By default, the image receives `2fr` and the title
stack receives `3fr`, independent of direction. Image variants expose an `image` cell except
`image-background`, whose image is the `title` cell background.

#verbatim-example("layouts/title.typ")
#thumbnail-gallery(
  calepin.elements.gallery,
  "layouts/title",
  9,
  "Nine structural title variants with inline academic metadata and images",
)

= `section()`

Creates a section-divider grid. The sole slide body is the section name. `subtitle`, `number`,
and `image` add context. Variants are `plain`, `image-left`, `image-right`,
`image-top`, `image-bottom`, and `image-background`; image variants require
`image`. A `number` may accompany any variant. Directional variants use the
same visual-order `tracks` syntax and transparent `image`/`section` split tree
as `image()`; `auto` gives the two cells equal space. `image-background`
keeps a single `section` cell and places the image behind it; as with the
title layout, darken or lighten the image itself and override the cell's
text fill when the composition needs light-on-dark text.

#verbatim-example("layouts/section.typ")
#thumbnail-gallery(calepin.elements.gallery, "layouts/section", 7, "layouts.section() directional and background variants")

= `image()`

An image-first layout with no header or footer cells:

- `"full"` gives the image the complete body area without an inset.
- `"figure"` contains the image within the normal slide inset.
- `"left"` places a full-bleed image cell before a companion body.
- `"right"` places a companion body before a full-bleed image cell.
- `"top"` places a full-bleed image cell above a companion body.
- `"bottom"` places a companion body above a full-bleed image cell.

Set `path` to let Mosaic create and place the image, including `width: 100%`
and `height: 100%`. The default `fit: "cover"` preserves the image's aspect
ratio while filling its cell; override it with `"contain"` or `"stretch"`.
Add `alt` for alternative text. Without `path`, the image cell remains a
normal slide body so native `image(...)` content can provide advanced options.

For the split variants, `tracks` accepts `auto` or two native Typst track sizes
such as `(2fr, 1fr)`. Track order follows visual order: left-to-right for
`left` and `right`, top-to-bottom for `top` and `bottom`. The cells are named
`image` and `body`. When `path` is set, only the companion body must be supplied
to `m.slide`.

== Full

#verbatim-example("layouts/image-full.typ")
#thumbnail-gallery(calepin.elements.gallery, "layouts/image-full", 1, "Full image")

== Figure

#verbatim-example("layouts/image-figure.typ")
#thumbnail-gallery(calepin.elements.gallery, "layouts/image-figure", 1, "Contained figure")

== Left

#verbatim-example("layouts/image-left.typ")
#thumbnail-gallery(calepin.elements.gallery, "layouts/image-left", 1, "Image on the left")

== Right

#verbatim-example("layouts/image-right.typ")
#thumbnail-gallery(calepin.elements.gallery, "layouts/image-right", 1, "Image on the right")

== Top

#verbatim-example("layouts/image-top.typ")
#thumbnail-gallery(calepin.elements.gallery, "layouts/image-top", 1, "Image on top")

== Bottom

#verbatim-example("layouts/image-bottom.typ")
#thumbnail-gallery(calepin.elements.gallery, "layouts/image-bottom", 1, "Image on the bottom")

= `table()`

Wraps a native Typst table or other tabular content. Use `title`, `caption`,
`source`, and `highlight` for explanation.
The native table remains content inside a `table` cell. Optional surrounding
rows use the IDs `title`, `highlight`, `caption`, and `source`.

#verbatim-example("layouts/table.typ")
#thumbnail-gallery(calepin.elements.gallery, "layouts/table", 4, "layouts.table() metadata configurations")

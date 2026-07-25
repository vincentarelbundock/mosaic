#import "/.calepin/calepin.typ" as calepin
#import "/_includes/tutorial-gallery.typ": (
  thumbnail-gallery,
  verbatim-example,
)

#set document(title: [Templates])
#metadata((title: "Templates")) <website-metadata>

#title()

The #link("getting-started.html")[Basics] guide introduced templates as
ready-made grids for familiar slide structures. Choose a function and, when
available, a `variant`; then pass the result to `m.slide(grid: ...)`.
Supply the slide's main content in `[...]` blocks after the call. The galleries
below are compiled from the source displayed beside them.

The common pattern is to create a slide function that combines the grid with
its slide options, then reuse that function with different content:

```typ
#let myslide = m.slide.with(
  grid: m.templates.default(variant: "header-body"),
  colors: m.color.scheme("dark"),
  numbered: true,
)

#myslide[== Slide title][Slide content]
```

This keeps structural options on the template constructor; slide behavior such
as `colors`, `background`, `foreground`, and `numbered` on `m.slide.with`; and
individual slide calls focused on content.

= `default()`

Creates one of four named region structures. `variant` accepts `"body"`,
`"header-body"`, `"body-footer"`, or `"header-body-footer"`; the complete
`"header-body-footer"` structure is the default. `columns` controls the number
of body cells, while `tracks` optionally sets their relative or fixed widths.
Mosaic uses `"header-body"` for automatic slides created with `==`.

For an explicit titled slide, write `==` in the header block. This keeps normal
Typst heading styling and registers the heading with outlines.

Set `progress` to `"1/1"`, `"1"`, `"circle"`, or `"line"` to add progress on the
slide foreground, or leave it as `none`. The indicator follows slide-local
colors. When the template includes a footer, it also follows the footer's
insets, text size, explicit text fill, and inverted color treatment.

== Regions

The variant determines which named regions are present and therefore the order
of the slide's content blocks:

- `variant: "body"` expects `[body]`.
- `variant: "header-body"` expects `[header][body]`.
- `variant: "body-footer"` expects `[body][footer]`.
- The default `variant: "header-body-footer"` expects `[header][body][footer]`.

This example shows the complete three-region structure:

#verbatim-example("templates/default-full.typ")
#thumbnail-gallery(
  calepin.elements.gallery,
  "templates/default-full",
  1,
  "A slide with header, body, and footer regions",
)

The header remains content-sized:

#verbatim-example("templates/default-header.typ")
#thumbnail-gallery(
  calepin.elements.gallery,
  "templates/default-header",
  1,
  "A slide with a header and one body region",
)

== Columns

`columns` divides the body into equal columns by default. Set `tracks` to an
array with one native Typst track size per column when their widths should
differ. Supply one body block per column, after any header block.

#verbatim-example("templates/default-columns.typ")
#thumbnail-gallery(
  calepin.elements.gallery,
  "templates/default-columns",
  1,
  "A slide with a header and three weighted body columns",
)

== Style

Use `fill`, `text`, `align`, and `inset` dictionaries to style regions by name.
Omitted region keys keep the setup defaults. List regions in `inverted` to fill
the header, footer, or both with the inherited scheme's `text` color and render
their content with `inverse-text`; for example, use
`inverted: ("footer",)` to invert only the footer. The body retains the normal
`canvas` and `text` roles. Explicit regional `fill` and `text` values override
those inherited defaults. Fills accept native Typst values, including
gradients. Use `background` with explicit native content such as `image(...)`
for a region background:

This example selects both surrounding regions:

#verbatim-example("templates/default-inverted.typ")
#thumbnail-gallery(
  calepin.elements.gallery,
  "templates/default-inverted",
  1,
  "A default slide with an inverted header and footer",
)

Regional dictionaries remain available for independent visual styling:

#verbatim-example("templates/default-images.typ")
#thumbnail-gallery(
  calepin.elements.gallery,
  "templates/default-images",
  1,
  "A slide with a solid header, darkened body image, and gradient footer",
)

== Wrapping

Header and footer regions keep their normal one-line height when possible.
Because their tracks are content-sized, wrapped text expands their fills
vertically and leaves the remaining height to the body.

#verbatim-example("templates/default-wrapping.typ")
#thumbnail-gallery(
  calepin.elements.gallery,
  "templates/default-wrapping",
  1,
  "A slide whose filled header and footer expand onto multiple lines",
)

== Reusable style

Use Typst's native `.with(...)` to save a configured template function. The
resulting `custom` shortcut can create as many grids as needed while each slide
continues to supply its own header, body, and footer.

#verbatim-example("templates/default-custom.typ")
#thumbnail-gallery(
  calepin.elements.gallery,
  "templates/default-custom",
  2,
  "Slides made with the reusable custom template",
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

Creates an opening-slide grid whose sole slide body is the title. The default
`"left-aligned"` variant is text-only. The complete set describes the rendered
structure: `"academic"`, `"left-aligned"`, `"centered-stack"`,
`"accent-block"`, `"image-left"`, `"image-right"`, `"image-top"`,
`"image-bottom"`, and `"image-background"`.

Every layout accepts `subtitle`, `authors`, and `date`. The ordinary text,
accent, and image layouts show author names and affiliations but omit contact
details. They compose these values in one title cell as two masses: the title
and subtitle sit tight together, then a short accent-colored rule separates
the metadata, which compresses to a byline plus one fine-print line joining
affiliations and date. `centered-stack` centers that
complete stack; every other text layout anchors it to the bottom edge.
`accent-block` runs a narrow accent-colored spine along the leading edge. The
default is `left-aligned`.

The `academic` structure requires a non-empty `authors` array of `author()`
objects. Mosaic de-duplicates affiliations by `id`, numbers them in first-seen
order, adds superscripts to author names, and generates one inline affiliation
legend. Reusing an ID with a different name is an error. A corresponding author
receives an asterisk. ORCID is represented only by the linked icon beside the
author's name.
The title and subtitle share the `title` cell. The `academic` layout
additionally uses an `authors` byline cell and a single fine-print `details`
cell that joins the affiliation legend, contact emails, and date on one line.
Absent optional regions are omitted.

Title grids suppress the presentation's global logo. Add a logo, event label,
or other decoration explicitly with the title slide's `foreground` argument;
an event may instead be written directly into `subtitle`:

```typ
#m.slide(
  grid: m.templates.title(
    subtitle: [Annual Research Lecture · Montréal, 2027],
  ),
  foreground: [
    #place(top + left)[#text(size: 10pt, weight: "bold")[RESEARCH LAB]]
    #place(top + right)[#image("logo.svg", width: 18mm)]
  ],
)[Models, evidence, and public decisions]
```

The five image variants require `image`, either native content, a non-empty path
string, or a dictionary with `path` plus optional `alt` and `fit`. For custom
image sizing or composition, pass native content instead of a path:

- `image-left` and `image-right` place a full-height image beside the title stack.
- `image-top` and `image-bottom` place a full-width image above or below the title stack.
- `image-background` covers the canvas, applies a deterministic alignment-aware
  readability gradient with inverse typography, and positions its text with native
  `panel-align`. Combine horizontal and vertical alignment, such as
  `panel-align: top + left` for a top-left title or `center + horizon` for a
  centered title.

For the four directional variants, `tracks` accepts `auto` or two native Typst
track sizes in visual order. By default, the image receives `2fr` and the title
stack receives `3fr`, independent of direction. Image variants expose an `image` cell except
`image-background`, whose image is the `title` cell background.

#verbatim-example("templates/title.typ")
#thumbnail-gallery(
  calepin.elements.gallery,
  "templates/title",
  9,
  "Nine structural title variants with an inline academic layout, realistic metadata, and images",
)

= `section()`

Creates a section-divider grid. The sole slide body is the section name. `subtitle`, `number`,
and `image` add context. Variants are `plain`, `image-left`, `image-right`,
`image-top`, `image-bottom`, and `image-background`; image variants require
`image`. A `number` may accompany any variant. Directional variants use the
same visual-order `tracks` syntax and transparent `image`/`section` split tree
as `image()`; `auto` gives the two regions equal space. `image-background`
keeps a single `section` cell and places the
image behind it with a black readability scrim and white text.

#verbatim-example("templates/section.typ")
#thumbnail-gallery(calepin.elements.gallery, "templates/section", 7, "templates.section() directional and background variants")

= `image()`

An image-first template with no header or footer regions:

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

#verbatim-example("templates/image-full.typ")
#thumbnail-gallery(calepin.elements.gallery, "templates/image-full", 1, "Full image")

== Figure

#verbatim-example("templates/image-figure.typ")
#thumbnail-gallery(calepin.elements.gallery, "templates/image-figure", 1, "Contained figure")

== Left

#verbatim-example("templates/image-left.typ")
#thumbnail-gallery(calepin.elements.gallery, "templates/image-left", 1, "Image on the left")

== Right

#verbatim-example("templates/image-right.typ")
#thumbnail-gallery(calepin.elements.gallery, "templates/image-right", 1, "Image on the right")

== Top

#verbatim-example("templates/image-top.typ")
#thumbnail-gallery(calepin.elements.gallery, "templates/image-top", 1, "Image on top")

== Bottom

#verbatim-example("templates/image-bottom.typ")
#thumbnail-gallery(calepin.elements.gallery, "templates/image-bottom", 1, "Image on the bottom")

= `table()`

Wraps a native Typst table or other tabular content. Use `title`, `caption`,
`source`, and `highlight` for explanation.
The native table remains content inside a `table` cell. Optional surrounding
rows use the IDs `title`, `highlight`, `caption`, and `source`.

#verbatim-example("templates/table.typ")
#thumbnail-gallery(calepin.elements.gallery, "templates/table", 4, "templates.table() metadata configurations")

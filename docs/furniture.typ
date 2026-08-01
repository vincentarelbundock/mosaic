#import "/.calepin/calepin.typ" as calepin
#import "/_includes/tutorial-gallery.typ": slideshow, verbatim-example

#set document(title: [Furniture])
#metadata((title: "Furniture")) <website-metadata>

#title()

Grids and cells occupy the main slide body. Two full-slide *planes* sit around
it — a background painted behind and a foreground painted over — and neither
changes the grid's row or column measurements. Together with headings, they
carry a deck's furniture: page numbers, logos, decoration, and navigation. Set a
recurring plane with `m.deck`, or pass one to a specific `m.slide`; a slide
inherits the deck plane by default, and `background: none` or `foreground: none`
omits it for one slide.

= Foreground

Foreground content is painted over the slide body. Deck foregrounds float above
every inherited grid; all incremental frames from one slide share a logical
slide number while their step and page numbers advance.

#verbatim-example("foreground/numbering.typ")

#slideshow(
  calepin.elements.gallery,
  "foreground/numbering",
  3,
  "Logical and physical numbering",
)

`foreground` accepts arbitrary Typst content and covers the full usable slide
area. Add any number of native `place` calls to position images, logos, text,
shapes, labels, or counters independently of the slide grid.

#verbatim-example("foreground/place.typ")

#slideshow(
  calepin.elements.gallery,
  "foreground/place",
  1,
  "Arbitrary foreground objects",
)

A logo is just placed foreground content: the alignment selects an anchor such
as `top + left` or `bottom + right`, and `dx`/`dy` offset it from there.

#verbatim-example("images/foreground.typ")

#slideshow(
  calepin.elements.gallery,
  "images/foreground",
  1,
  "Logo in the foreground",
)

= Background

Background content is painted behind the slide body over the full usable area.
Native `place` positions images, shapes, and other Typst content independently
of the grid; a light wash on a photograph improves contrast with foreground
text.

#verbatim-example("background/placement.typ")

#slideshow(
  calepin.elements.gallery,
  "background/placement",
  1,
  "Placed background content",
)

= Navigation

Because Mosaic keeps Typst headings native, the same headings that create
slides can drive tables of contents, breadcrumbs, and links between sections.

== Table of contents

Use Typst's `outline` to create a table of contents. Set `depth: 2` to include
sections and slides, or a smaller depth for a shorter overview. Every entry
links to its heading.

#verbatim-example("navigation/outline.typ")

#slideshow(
  calepin.elements.gallery,
  "navigation/outline",
  5,
  "A linked table of contents",
)

== Breadcrumbs

`m.current-heading()` returns the active section heading;
`m.current-heading(level: 2)` the active slide heading. Their `body` fields
provide the labels, and `location()` provides a link target.

#verbatim-example("navigation/breadcrumb.typ")

#slideshow(
  calepin.elements.gallery,
  "navigation/breadcrumb",
  3,
  "Section and slide breadcrumbs",
)

== Section links

Use `query(heading.where(level: 1, outlined: true))` to collect every outlined
section heading. Each result provides a label through `body` and a destination
through `location()`. Compare it with `current-heading()` to style the active
section differently.

#verbatim-example("navigation/sections.typ")

#slideshow(
  calepin.elements.gallery,
  "navigation/sections",
  3,
  "Clickable section navigation",
)

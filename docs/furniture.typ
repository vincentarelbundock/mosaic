#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example, slideshow

#set document(title: [Furniture])
#metadata((title: "Furniture")) <website-metadata>

#title()

Grids and cells occupy the main slide body. Two full-slide *planes* sit around
it (a background painted behind and a foreground painted over), and neither
changes the grid's row or column measurements. Together with headings, they
carry a deck's furniture: page numbers, logos, decoration, and navigation. Set a
recurring plane through `m.setup`, or address one on a specific `m.slide`
through the reserved `background` and `foreground` entries of its `content:`
dictionary. A slide inherits the deck plane by default; a content entry
replaces it for that slide, and an entry set to `none` omits it. Each rendered
plane is labeled like a cell (`<mosaic-cell-background>` and
`<mosaic-cell-foreground>`), so native `show label(...)` rules style planes
too.

= Foreground

Foreground content is painted over the slide body. Deck foregrounds float above
every inherited grid. Built-in slide numbering and progress are enabled through
`setup(features:)`; all incremental frames from one slide share a logical slide
number.

#embedded-example(
  calepin.elements.gallery,
  "furniture/slide-numbering",
  frames: 2,
  title: "Logical and physical numbering",
)

`foreground` accepts arbitrary Typst content and covers the full usable slide
area. Add any number of native `place` calls to position images, logos, text,
shapes, labels, or counters independently of the slide grid.

#embedded-example(
  calepin.elements.gallery,
  "furniture/foreground-content",
  frames: 1,
  title: "Arbitrary foreground objects",
)

A logo is just placed foreground content: the alignment selects an anchor such
as `top + left` or `bottom + right`, and `dx`/`dy` offset it from there.

#embedded-example(
  calepin.elements.gallery,
  "furniture/foreground-image",
  frames: 1,
  title: "Logo in the foreground",
)

= Progress

`m.components.progress()` shows the current position in a deck. Progress
follows Mosaic's logical slide counter automatically, including when a slide
has multiple incremental frames. Use `"1/1"` or `"1"` for numbers, `"circle"`
for a compact corner indicator, and `"line"` for an edge-to-edge bar. Each
variant below sits on the slide foreground, but the component is ordinary
#link("content.html")[content] and can be used in any cell or native container.

#embedded-example(
  calepin.elements.gallery,
  "blocks/progress-numbers",
  frames: 3,
  title: "layouts.default(progress: \"1/1\")",
)

#slideshow(
  calepin.elements.gallery,
  "blocks/progress-line",
  3,
  "layouts.default(progress: \"line\")",
)

Add a progress indicator to any layout, or to a custom grid, through the
reserved `foreground` entry of `content:`. Here `slide-progress()` builds a
two-column slide with a foreground bar:

#embedded-example(
  calepin.elements.gallery,
  "blocks/progress-custom-layout",
  frames: 3,
  title: "A reusable custom-grid slide function with foreground progress",
)

= Background

Background content is painted behind the slide body over the full usable area.

== Placed content

Native `place` positions images, shapes, and other Typst content independently
of the grid.

#embedded-example(
  calepin.elements.gallery,
  "furniture/background-content",
  frames: 1,
  title: "Placed background content",
)

== Photographic backgrounds

Pass a slide-sized image through the reserved `background` entry. The optional
`lighten` and `darken` washes of `m.components.image()` quiet the photograph
and improve contrast with the text in front of it.

#embedded-example(
  calepin.elements.gallery,
  "blocks/background-image",
  frames: 1,
  title: "Full-slide background image",
)

= Navigation

Because Mosaic keeps Typst headings native, the same headings that create
slides can drive tables of contents, breadcrumbs, and links between sections.

== Table of contents

Use Typst's `outline` to create a table of contents. Set `depth: 2` to include
sections and slides, or a smaller depth for a shorter overview. Every entry
links to its heading.

#embedded-example(
  calepin.elements.gallery,
  "furniture/outline",
  frames: 5,
  title: "A linked table of contents",
)

== Breadcrumbs

Use native contextual `query` with a selector ending at `here()` to find the
active section and slide headings. Their `body` fields provide the labels, and
`location()` provides a link target.

#embedded-example(
  calepin.elements.gallery,
  "furniture/breadcrumbs",
  frames: 3,
  title: "Section and slide breadcrumbs",
)

== Section links

Use `query(heading.where(level: 1, outlined: true))` to collect every outlined
section heading. Each result provides a label through `body` and a destination
through `location()`. Compare it with the last matching heading before `here()`
to style the active section differently.

#embedded-example(
  calepin.elements.gallery,
  "furniture/section-links",
  frames: 3,
  title: "Clickable section navigation",
)

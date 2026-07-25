#import "/.calepin/calepin.typ" as calepin
#import "/_includes/tutorial-gallery.typ": slideshow, verbatim-example

#set document(title: [Navigation])
#metadata((title: "Navigation")) <website-metadata>

#title()

The #link("getting-started.html")[Basics] guide uses headings to create slides, while
#link("incremental.html")[Reveal or replace] adds frames without changing that
structure. Because Mosaic keeps Typst headings native, the same headings can
drive tables of contents, breadcrumbs, and links between sections.

= Table of contents

Use Typst's `outline` to create a table of contents. Set `depth: 2` to include
sections and slides, or use a smaller depth for a shorter overview. Every
outline entry links to its heading.

#verbatim-example("navigation/outline.typ")

#slideshow(
  calepin.elements.gallery,
  "navigation/outline",
  5,
  "A linked table of contents",
)

= Breadcrumbs

`m.current-heading()` returns the active section heading.
`m.current-heading(level: 2)` returns the active slide heading. Their
`body` fields provide the labels, while `location()` provides a link target.

#verbatim-example("navigation/breadcrumb.typ")

#slideshow(
  calepin.elements.gallery,
  "navigation/breadcrumb",
  3,
  "Section and slide breadcrumbs",
)

= Section links

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

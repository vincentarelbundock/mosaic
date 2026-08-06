#import "/_calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example

#set document(title: [Navigation])
#metadata((title: "Navigation")) <website-metadata>

#title()

Because Mosaic keeps Typst headings native, the same headings that create slides can drive tables of contents, breadcrumbs, and links between sections.

= Table of contents

Use Typst's `outline` to create a table of contents. Set `depth: 2` to include sections and slides, or a smaller depth for a shorter overview. Every entry links to its heading.

#embedded-example(
  calepin.elements.gallery,
  "furniture/outline",
  frames: 5,
  title: "A linked table of contents",
)

= Breadcrumbs

Use native contextual `query` with a selector ending at `here()` to find the active section and slide headings. Their `body` fields provide the labels, and `location()` provides a link target.

#embedded-example(
  calepin.elements.gallery,
  "furniture/breadcrumbs",
  frames: 3,
  title: "Section and slide breadcrumbs",
)

= Section links

Use `query(heading.where(level: 1, outlined: true))` to collect every outlined section heading. Each result provides a label through `body` and a destination through `location()`. Compare it with the last matching heading before `here()` to style the active section differently.

#embedded-example(
  calepin.elements.gallery,
  "furniture/section-links",
  frames: 3,
  title: "Clickable section navigation",
)

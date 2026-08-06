#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example

#set document(title: [Components])
#metadata((title: "Components")) <website-metadata>

#title()

`m.components` provides reusable Typst content to place inside cells, or inside any native Typst composition. None of these create slides or grids on their own; they are values you place in a cell, a background, a foreground, or any native Typst composition. Each function has an independent example and gallery. One member, `m.components.progress()`, is documented with the deck infrastructure on the #link("../presenting/footer.html")[Footer and progress] page; it is ordinary content all the same and can sit in any cell.

= `card()`

Wrap content in a clipped, bordered panel.

#embedded-example(
  calepin.elements.gallery,
  "blocks/component-card",
  frames: 2,
  title: "components.card()",
)

= `callout()`

Emphasize content with a colored side stripe and an optional title.

#embedded-example(
  calepin.elements.gallery,
  "blocks/component-callout",
  frames: 1,
  title: "components.callout()",
)

= `badge()`

Create a compact inline badge with configurable corners and text styling.

#embedded-example(
  calepin.elements.gallery,
  "blocks/component-badge",
  frames: 1,
  title: "components.badge()",
)

= `quote()`

Typeset a borderless quotation with an optional attribution.

#embedded-example(
  calepin.elements.gallery,
  "blocks/component-quote",
  frames: 1,
  title: "components.quote()",
)

= `divider()`

Separate content with a horizontal line, with or without a label.

#embedded-example(
  calepin.elements.gallery,
  "blocks/component-divider",
  frames: 1,
  title: "components.divider()",
)

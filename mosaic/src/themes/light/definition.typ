// Canonical passive Light theme definition.
#import "../../color-defaults.typ": default-colors
#import "layouts.typ" as layouts

#let definition = (
  name: "Light",
  colors: default-colors,
  normalize-lists: false,
  layouts: (
    content: layouts.content(variant: "header-body"),
    title: layouts.title(),
    section: layouts.section(),
  ),
)

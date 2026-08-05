#import "@local/mosaic:0.0.1" as m

#show: m.setup.with(
  cells: (footer: [Mosaic · Engineering]),
)

#let layout = m.layouts.content(variant: "header-body-footer")

#m.slide(
  layout: layout,
  cells: (
    header: [DEFAULT FOOTER],
    body: [The footer comes from `m.setup(cells:)`.],
  ),
)

#m.slide(
  layout: layout,
  cells: (
    header: [SLIDE OVERRIDE],
    body: [Explicit slide content has precedence.],
    footer: [Confidential · Draft],
  ),
)

#m.slide(
  layout: layout,
  cells: (
    header: [SUPPRESSED FOOTER],
    body: [Use `none` to omit the inherited value.],
    footer: none,
  ),
)

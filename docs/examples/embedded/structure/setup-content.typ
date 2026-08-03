#import "@local/mosaic:0.0.1" as m

#show: m.setup.with(
  content: (footer: [Mosaic · Engineering]),
)

#let layout = m.layouts.content(variant: "header-body-footer")

#m.slide(
  layout: layout,
  content: (
    header: [DEFAULT FOOTER],
    body: [The footer comes from `m.setup(content:)`.],
  ),
)

#m.slide(
  layout: layout,
  content: (
    header: [SLIDE OVERRIDE],
    body: [Explicit slide content has precedence.],
    footer: [Confidential · Draft],
  ),
)

#m.slide(
  layout: layout,
  content: (
    header: [SUPPRESSED FOOTER],
    body: [Use `none` to omit the inherited value.],
    footer: none,
  ),
)

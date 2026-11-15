#import "@local/mosaic:0.0.3" as m

#show: m.setup.with(
  cells: (
    footer: "SETUP FOOTER",
    unused-cell: [IGNORED DEFAULT],
  ),
)

// Named content can provide header and body while inheriting the setup footer.
#m.slide(
  layout: m.layouts.content(variant: "header-body-footer"),
  cells: (
    header: [NAMED HEADER],
    body: [NAMED BODY],
  ),
)

// Naming every cell overrides every setup default. Positional bodies never
// reach a defaulted cell: `footer` is addressed by name.
#m.slide(
  layout: m.layouts.content(variant: "header-body-footer"),
  cells: (
    header: [FULL HEADER],
    body: [FULL BODY],
    footer: [FULL FOOTER],
  ),
)

// Named content may be partial when setup supplies the remainder.
#m.slide(
  layout: m.layouts.content(variant: "header-body-footer"),
  cells: (
    header: [NAMED HEADER],
    body: [NAMED BODY],
  ),
)

// Explicit named content overrides a setup default.
#m.slide(
  layout: m.layouts.content(variant: "header-body-footer"),
  cells: (
    header: [OVERRIDE HEADER],
    body: [OVERRIDE BODY],
    footer: [NAMED FOOTER],
  ),
)

// none suppresses an inherited cell default.
#m.slide(
  layout: m.layouts.content(variant: "header-body-footer"),
  cells: (
    header: [SUPPRESS HEADER],
    body: [SUPPRESS BODY],
    footer: none,
  ),
)

// Defaults for absent cell IDs do not constrain another layout.
#m.slide(layout: m.layouts.content(variant: "body"))[BODY ONLY]

#context assert(counter(page).final().first() == 6)

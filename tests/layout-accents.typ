#import "@local/mosaic:0.0.1" as mosaic

#let accent = rgb("#123456")
#let layout = mosaic.layouts.default(
  variant: "header-body",
  progress: "line",
  accent: accent,
)
#assert(layout.fields.accent == accent)

#let title-accent = rgb("#654321")
#let title-layout = mosaic.layouts.title(
  [Explicit title accent],
  variant: "accent-block",
  accent: title-accent,
)
#assert(title-layout.fields.accent == title-accent)

#let section-accent = rgb("#a1b2c3")
#let section-layout = mosaic.layouts.section(
  number: [03],
  accent: section-accent,
)
#assert(section-layout.fields.accent == section-accent)
#assert("role" not in section-layout.fields)


#show: mosaic.setup
#mosaic.slide(layout)[
  == Explicit layout accent
][
  The foreground progress line uses the layout accent.
]

#mosaic.slide(title-layout)

#mosaic.slide(section-layout)[Section accent]

#let body-accent = rgb("#bc3172")
#mosaic.slide(mosaic.layouts.default(
  variant: "body",
  progress: "line",
  accent: body-accent,
))[Body accent]



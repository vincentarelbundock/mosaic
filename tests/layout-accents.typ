#import "@local/mosaic:0.0.1" as mosaic

#let title-accent = rgb("#654321")
#let title-layout = mosaic.layouts.title(
  title: [Explicit title accent],
  // Swiss draws its baseline rule in the explicit accent when one is given.
  variant: "swiss",
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
#mosaic.slide(layout: title-layout)
#mosaic.slide(layout: section-layout)[Section accent]

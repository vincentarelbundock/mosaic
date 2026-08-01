#import "@local/mosaic:0.0.1" as mosaic

#let public-layout-names = (
  "default", "title", "section", "image", "table",
)
#assert(public-layout-names.all(name => name in mosaic.layouts))

#let brand = mosaic.setup.with(
  colors: (text: rgb("#17324d"), accent: rgb("#e69f00")),
  features: (rounded: true, slide-number: true),
)
#let title-grid = mosaic.layouts.title(
  [Mosaic],
  subtitle: [A compact semantic layout system],
  authors: (mosaic.author([Mosaic contributors]),),
  date: [2026],
)

#show: brand
#mosaic.slide(grid: title-grid)

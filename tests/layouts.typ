#import "@local/mosaic:0.0.1" as mosaic

#let public-layout-names = (
  "default", "title", "section", "author",
)
#assert(public-layout-names.all(name => name in mosaic.layouts))

#let brand = mosaic.setup.with(
  features: (slide-number: true),
)
#let title-grid = mosaic.layouts.title(
  [Mosaic],
  subtitle: [A compact semantic layout system],
  authors: (mosaic.layouts.author([Mosaic contributors]),),
  date: [2026],
  accent: rgb("#e69f00"),
)

#show: brand
#set text(fill: rgb("#17324d"))
#mosaic.slide(grid: title-grid)

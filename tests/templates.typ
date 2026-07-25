#import "@local/mosaic:0.0.1" as mosaic

#let public-template-names = (
  "default", "title", "section", "image", "table",
)
#assert(public-template-names.all(name => name in mosaic.templates))

#let brand = mosaic.setup.with(
  colors: (text: rgb("#17324d"), accent: rgb("#e69f00")),
  features: (rounded: true, slide-number: true),
)
#let title-grid = mosaic.templates.title(
  subtitle: [A compact semantic template system],
  authors: (mosaic.author([Mosaic contributors]),),
  date: [2026],
)

#show: brand
#mosaic.slide(grid: title-grid)[Mosaic]

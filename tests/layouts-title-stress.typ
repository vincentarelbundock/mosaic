// Details boxes grow with their content up to a cap of their region and then
// scale down to hold it (capped-fit), so a deck with many authors compresses
// its metadata instead of colliding with the heading or the photograph. A
// dozen authors across four institutions is far past every cap; every variant
// must still compile with the heading clear of the details.
#import "@preview/mosaic:0.0.1" as mosaic

#let institutions = (
  [Centre for Comparative Politics],
  [European Institute for Social Data],
  [Laboratory for Public Evidence],
  [East Asia Methods Centre],
)
#let authors = range(12).map(index => mosaic.layouts.author(
  [Author #str(index + 1) Surname],
  affiliations: (institutions.at(calc.rem(index, 4)),),
  email: if calc.rem(index, 3) == 0 { "author" + str(index + 1) + "@example.org" } else { none },
  corresponding: index == 0,
))

#show: mosaic.setup.with(
  title: [Measurement under pressure],
  subtitle: [A stress test of the title metadata caps],
  authors: authors,
  date: [Toronto · July 2027],
)

#mosaic.slide(layout: "title", variant: "centered")
#mosaic.slide(layout: "title", variant: "bordered")
#mosaic.slide(layout: "title", variant: "ruled")
#mosaic.slide(layout: "title", variant: "kicker")
#mosaic.slide(layout: "title", variant: "panel")
#mosaic.slide(layout: "title", variant: "academic")
#mosaic.slide(
  layout: "title",
  variant: "image",
  position: "top",
  image: path("/docs-src/assets/images/title-river.webp"),
)

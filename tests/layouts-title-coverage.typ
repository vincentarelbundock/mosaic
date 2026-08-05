// The title layout's field contract, one variant per page: every variant must
// render every `setup` deck field and every `author()` field. The test runner
// asserts each page carries the title, subtitle, both names, both
// affiliations, both contact addresses, and the date, so a variant that drops
// a field fails the run rather than shipping a title page with an author's
// information missing.
#import "@local/mosaic:0.0.1" as mosaic

#let authors = (
  mosaic.layouts.author(
    [Ada Lovelace],
    affiliations: ([Analytical Society], [University of London]),
    email: "ada@example.org",
    orcid: "0000-0002-1825-0097",
    corresponding: true,
  ),
  mosaic.layouts.author(
    [Charles Babbage],
    affiliations: ([University of London],),
    email: "babbage@example.org",
  ),
)

#show: mosaic.setup.with(
  title: [Provable coverage],
  subtitle: [Every field on every variant],
  authors: authors,
  date: [2026-08-05],
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
  image: path("/docs/assets/images/title-river.webp"),
)
// The contract holds under inversion too.
#mosaic.slide(layout: "title", variant: "ruled", invert: true)

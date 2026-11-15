// A slide that fits is not an overflow. Every title variant scales a long
// title and a long author list into its cell, so `overflow: "error"` must
// compile this deck: nothing here is clipped. The image variant is included
// beside the picture, in a band above it, and over a background.
#import "@local/mosaic:0.0.3" as mosaic

#let authors = range(8).map(index => mosaic.layouts.author(
  [Author Number #str(index)],
  affiliations: ([University #str(calc.rem(index, 3))],),
  email: "author" + str(index) + "@example.org",
))

#show: mosaic.setup.with(
  title: [A rather long title that wraps over several lines to test the collision behaviour of each variant in turn and then keeps going],
  subtitle: [A subtitle that is also long enough to wrap onto a second line of its own],
  authors: authors,
  date: [2026],
  overflow: "error",
)

#for variant in ("centered", "bordered", "ruled", "kicker", "panel", "academic") {
  mosaic.slide(layout: "title", variant: variant)
}
#for variant in ("image-left", "image-top", "image-background") {
  mosaic.slide(
    layout: "title",
    variant: variant,
    image: path("/docs-src/assets/images/title-river.webp"),
  )
}

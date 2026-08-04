#import "@local/mosaic:0.0.1" as mosaic
#import "../mosaic/src/author.typ": analyze-authors

#let udem = [Université de Montréal]
#let cirano = [CIRANO]
#let ada = mosaic.layouts.author(
  [Ada Lovelace],
  affiliations: (udem, cirano),
  email: "ada@example.org",
  orcid: "0000-0001-2345-6789",
  corresponding: true,
)
#assert(ada.name == [Ada Lovelace])
#assert(ada.affiliations == (udem, cirano))
#assert(ada.email == "ada@example.org")
#assert(ada.orcid == "0000-0001-2345-6789")
#assert(ada.corresponding)

#let grace = mosaic.layouts.author(
  [Grace Hopper],
  affiliations: (cirano,),
)
#assert(grace.email == none)
#assert(grace.orcid == none)
#assert(not grace.corresponding)

// Affiliations are deduplicated by value, so the legend lists each institution
// once and the authors sharing it share its number.
#let analyzed = analyze-authors((ada, grace))
#assert(analyzed.affiliations == (udem, cirano))
#assert(analyzed.authors.at(0).numbers == (1, 2))
#assert(analyzed.authors.at(1).numbers == (2,))

// A string and the same text as content name one institution, not two.
#let mixed = analyze-authors((
  mosaic.layouts.author([Ada], affiliations: ("CIRANO",)),
  mosaic.layouts.author([Grace], affiliations: ([CIRANO],)),
))
#assert(mixed.affiliations.len() == 1)
#assert(mixed.authors.at(1).numbers == (1,))

#show: mosaic.setup
#mosaic.slide(layout: mosaic.layouts.title(
  title: [A public academic title],
  variant: "academic",
  authors: (ada, grace),
))

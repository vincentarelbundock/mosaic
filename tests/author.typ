#import "@local/mosaic:0.0.1" as mosaic

#let udem = (id: "udem", name: [Université de Montréal])
#let cirano = (id: "cirano", name: [CIRANO])
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

#show: mosaic.setup
#mosaic.slide(layout: mosaic.layouts.title(
  [A public academic title],
  variant: "academic",
  authors: (ada, grace),
))

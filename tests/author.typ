#import "@local/mosaic:0.0.1" as mosaic
#import "../mosaic/src/author.typ": analyze-authors, plain-name, resolve-authors

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

// A bare name is one author, so `authors:` reads like `subtitle:` and `date:`
// whenever the name carries nothing else.
#assert(resolve-authors([Ada Lovelace]).len() == 1)
#assert(resolve-authors([Ada Lovelace]).at(0).name == [Ada Lovelace])
#assert(resolve-authors("Ada Lovelace").at(0).name == "Ada Lovelace")
#assert(resolve-authors(()) == ())

// Names and records mix in one array, and a coerced name is an ordinary record.
#let mixed-list = resolve-authors(([Grace Hopper], ada, "Alan Turing"))
#assert(mixed-list.len() == 3)
#assert(mixed-list.at(0).affiliations == ())
#assert(not mixed-list.at(0).corresponding)
#assert(mixed-list.at(1) == ada)
#assert(mixed-list.map(author => author.name) == (
  [Grace Hopper], [Ada Lovelace], "Alan Turing",
))

// A record already resolved stays untouched, so resolution is idempotent.
#assert(resolve-authors(mixed-list) == mixed-list)

// A name written as content still reaches Typst's document author metadata,
// which takes strings only. Markup inside one flattens to its words.
#assert(plain-name("Ada Lovelace") == "Ada Lovelace")
#assert(plain-name([Ada Lovelace]) == "Ada Lovelace")
#assert(plain-name([Grace #emph[M.] Hopper]) == "Grace M. Hopper")
#assert(plain-name([Ada#linebreak()Lovelace]) == "Ada Lovelace")

// A name with no plain reading suppresses the metadata rather than guessing.
#assert(plain-name(image("../docs/assets/images/dog.webp", width: 1pt)) == none)

// Coerced names carry no affiliations, so they add nothing to the legend.
#let legend = analyze-authors((ada, [Alan Turing]))
#assert(legend.affiliations == (udem, cirano))
#assert(legend.authors.at(1).numbers == ())

#show: mosaic.setup.with(authors: ([Ada Lovelace], [Grace Hopper]))
#mosaic.slide(layout: mosaic.layouts.title(
  title: [A public academic title],
  variant: "academic",
  authors: (ada, grace),
))

// The deck's own author list, written as two plain names, inherited by a
// compact variant through `auto`.
#mosaic.slide(layout: "title", title: [Two names, no records])

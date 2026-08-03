#import "@local/mosaic:0.0.1" as m

#let authors = (
  m.layouts.author(
    "Ada Lovelace",
    affiliations: ((id: "platform", name: [Platform Engineering]),),
  ),
)

#show: m.setup.with(
  title: [INHERITED TITLE],
  subtitle: [INHERITED SUBTITLE],
  authors: authors,
  date: [INHERITED DATE],
  colors: (
    canvas: rgb("#f5f7fb"),
    accent: rgb("#7c3aed"),
  ),
)

#context {
  let entries = query(<mosaic-deck-metadata>)
  assert(entries.len() == 1)
  let deck = entries.first().value
  assert(deck.title == [INHERITED TITLE])
  assert(deck.subtitle == [INHERITED SUBTITLE])
  assert(deck.authors == authors)
  assert(deck.date == [INHERITED DATE])
  assert(document.title == [INHERITED TITLE])
  assert(document.author == ("Ada Lovelace",))
}

#m.slide(
  layout: m.layouts.title(),
  numbered: false,
)

#m.slide(
  layout: m.layouts.title(
    title: [EXPLICIT TITLE],
    subtitle: none,
    authors: (),
    date: none,
  ),
  numbered: false,
)

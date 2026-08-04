#import "@local/mosaic:0.0.1" as m

#let authors = (
  m.layouts.author(
    "Ada Lovelace",
    affiliations: ([Platform Engineering],),
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
  // The swiss title rule takes the text color, so the configured accent's
  // path to the rendered page is verified through a component that resolves
  // the accent role.
  content: (
    foreground: place(bottom + right, dx: -12pt, dy: -12pt, m.components.label(role: "accent")[deck]),
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

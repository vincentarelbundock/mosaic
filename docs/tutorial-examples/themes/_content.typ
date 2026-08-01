// Shared content for the one-deck-many-themes demo. Each themes/<slug>.typ
// wrapper pairs this content with one theme file; only the theme import
// differs between wrappers.
#import "@local/mosaic:0.0.1" as m

#let title-info = arguments(
  [One deck, many themes],
  subtitle: [The same content, restyled by one import line],
  authors: (m.author([Priya Nair]), m.author([Noah Williams])),
  date: [July 2026],
)

#let points = m.reveal[
  - A theme is one ordinary Typst module.
  - It exports `apply` plus `title`, `section`, and `default` layouts.
  - Swap the look by changing a single import line.
]

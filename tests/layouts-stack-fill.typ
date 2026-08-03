#import "@local/mosaic:0.0.1" as mosaic

// A title or section cell composes several typographic tiers inside one cell.
// The subordinate tiers pin a muted fill for the default surface, but one
// label-targeted rule must recolor the whole stack: that is the only way to
// author a light-on-dark title over a photographic background.
#show: mosaic.setup

#let authors = (mosaic.layouts.author("Ada Lovelace"),)

// Page 1: no override. Title in the text color, subtitle and metadata muted.
#mosaic.slide(layout: mosaic.layouts.title(
  [Stack default],
  subtitle: [Muted subtitle],
  authors: authors,
  date: [2026],
))

// Page 2: one rule recolors title, subtitle, and metadata alike.
#[
  #show label("mosaic-cell-title"): set text(fill: rgb("#fedcba"))
  #mosaic.slide(layout: mosaic.layouts.title(
    [Stack override],
    subtitle: [Overridden subtitle],
    authors: authors,
    date: [2026],
  ))
]

// Page 3: the section subtitle follows the section cell the same way.
#[
  #show label("mosaic-cell-section"): set text(fill: rgb("#abcdef"))
  #mosaic.slide(layout: mosaic.layouts.section(subtitle: [Overridden tagline]))[
    Section
  ]
]

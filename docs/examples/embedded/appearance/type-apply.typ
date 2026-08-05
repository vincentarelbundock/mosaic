#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.light as m
#import "_tour-deck.typ": deck

// The same four rules, carried by a theme instead of the deck. `apply` runs the
// light theme's own rules first, then layers these on top.
#let serif = m.definition + (
  name: "Serif",
  apply: (body, colors: (:), options: (:)) => {
    show: (m.definition.apply).with(colors: colors, options: options)
    set text(font: "Libertinus Serif", size: 30pt)
    show heading: set text(weight: "regular", style: "italic")
    show label("mosaic-cell-section"): set text(weight: "regular")
    show label("mosaic-title-display"): set text(weight: "regular")
    body
  },
)

#show: mosaic.themes.setup(serif)

#deck(m)

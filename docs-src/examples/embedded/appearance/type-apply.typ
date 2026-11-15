#import "@local/mosaic:0.0.3" as mosaic
#import mosaic.themes.default as m
#import "_tour-deck.typ": deck

// The same choices, carried by a theme instead of the deck. The typeface and
// base size become the theme's `defaults`; `apply` runs the default theme's
// own rules first, then layers the three show rules on top.
#let serif = m.definition + (
  name: "Serif",
  defaults: m.definition.defaults + (
    font: "Libertinus Serif",
    base-size: 22pt,
  ),
  apply: (body, colors: (:), options: (:)) => {
    show: (m.definition.apply).with(colors: colors, options: options)
    show heading: set text(weight: "regular", style: "italic")
    show label("mosaic-cell-section"): set text(weight: "regular")
    show label("mosaic-title-display"): set text(weight: "regular")
    body
  },
)

#show: mosaic.themes.setup(serif)

#deck(m)

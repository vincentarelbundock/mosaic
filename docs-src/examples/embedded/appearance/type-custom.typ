#import "@local/mosaic:0.0.3" as mosaic
#import mosaic.themes.default as m
#import "_tour-deck.typ": deck

// The typeface and base size are deck options, so they go to `setup`.
#show: m.setup.with(font: "Libertinus Serif", base-size: 22pt)

// Native rules, written after `setup`, layer on top of the theme's own.
#show heading: set text(weight: "regular", style: "italic")
#show label("mosaic-cell-section"): set text(weight: "regular")
#show label("mosaic-title-display"): set text(weight: "regular")

#deck(m)

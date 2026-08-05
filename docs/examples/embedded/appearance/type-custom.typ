#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.light as m
#import "_tour-deck.typ": deck

#show: m.setup

// Native rules, written after `setup`, layer on top of the theme's own.
#set text(font: "Libertinus Serif", size: 30pt)
#show heading: set text(weight: "regular", style: "italic")
#show label("mosaic-cell-section"): set text(weight: "regular")
#show label("mosaic-title-display"): set text(weight: "regular")

#deck(m)

// `density` is the theme's option, so its setup accepts it as a named argument.
#import "_option-theme.typ" as m
#import "_tour-deck.typ": deck

#show: m.setup.with(density: "dense")

#deck(m)

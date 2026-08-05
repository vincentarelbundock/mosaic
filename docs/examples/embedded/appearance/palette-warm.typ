#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.light as m
#import "_tour-deck.typ": deck

#show: m.setup.with(
  colors: (
    canvas: rgb("#fdf6ee"),
    surface: rgb("#fffdfa"),
    text: rgb("#2b1d12"),
    muted: rgb("#8a7462"),
    line: rgb("#ead9c6"),
    accent: rgb("#b4530a"),
  ),
)

#deck(m)

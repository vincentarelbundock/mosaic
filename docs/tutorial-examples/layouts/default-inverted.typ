#import "@local/mosaic:0.0.1" as m
#show: m.setup

#let myslide = m.slide.with(
  grid: m.layouts.default(inverted: ("header", "footer")),
  colors: m.color.scheme("gallery"),
)

#myslide[
  == Inverted header and footer
][
  #lorem(36)
][
  Both regions inherit their inverse colors from the active scheme.
]

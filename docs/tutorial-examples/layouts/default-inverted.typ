#import "@local/mosaic:0.0.1" as m
#show: m.setup

// Invert a cell by filling it with the scheme's text color and switching its
// own text to the inverse. Read the colors from the active scheme so the
// rules track it.
#let colors = m.color.scheme("gallery")
#let invert(id) = it => {
  show label("mosaic-cell-" + id): set text(fill: colors.inverse-text)
  show label("mosaic-cell-" + id): body => block(
    width: 100%,
    fill: colors.text,
    body,
  )
  it
}
#show: invert("header")
#show: invert("footer")

#let myslide = m.slide.with(
  grid: m.layouts.default(),
  colors: colors,
)

#myslide[
  == Inverted header and footer
][
  #lorem(36)
][
  Both regions inherit their inverse colors from the active scheme.
]

#import "@local/mosaic:0.0.1" as m
#let theme = (
  colors: (
    canvas: white,
    surface: white,
    text: black,
    muted: gray,
    line: gray,
    accent: blue,
  ),
  options: (paper: "16-9"),
)
#show: m.theme.setup(theme)
== INVALID

#import "@local/mosaic:0.0.3" as mosaic

// A theme that states only its colors: the engine sets the ink from the
// resolved palette, so the text is legible on the dark canvas without the
// theme's `apply` restating it. A deck-level palette override follows too.
#let ink = rgb("#f0f0f0")
#let theme = (
  colors: (
    canvas: rgb("#0b1020"), surface: rgb("#161d33"),
    text: white, muted: rgb("#9aa4c0"),
    line: rgb("#2a3350"), accent: rgb("#7cc4ff"),
    warning: rgb("#fbbf24"), error: rgb("#f87171"),
  ),
)
#show: mosaic.themes.setup(theme).with(colors: (text: ink))

== Slide

#context assert(text.fill == ink, message: repr(text.fill))

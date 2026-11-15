#import "@local/mosaic:0.0.3" as mosaic

// A deck that sets its own syntax highlighting theme keeps it on an inverted
// slide: inversion swaps only a theme Mosaic chose for the canvas. Page 1 is
// an ordinary slide, page 2 its inverted twin; the runner reads the keyword
// fill from the SVG and expects the deck's own on both.
#show: mosaic.setup.with(foreground: none)
#set raw(theme: "support/code-custom.tmTheme")

#let code = ```python
def f(x): return "s" + 1
```

#mosaic.slide(code)
#mosaic.slide(invert: true, code)

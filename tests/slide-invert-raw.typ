#import "@local/mosaic:0.0.3" as mosaic

// An inverted slide re-derives the syntax highlighting theme from its own
// canvas. Page 1 is an ordinary slide of a light deck, page 2 its inverted
// twin; the runner reads the token fills from the SVG. Compiled a second time
// with `--input theme=mono`, where the deck is dark and the code panel must
// follow the inverted palette too.
#let theme-name = sys.inputs.at("theme", default: "default")
#let theme = dictionary(mosaic.themes).at(theme-name)
#show: theme.setup.with(foreground: none)

#let code = ```python
def f(x): return "s" + 1
```

#mosaic.slide(code)
#mosaic.slide(invert: true, code)

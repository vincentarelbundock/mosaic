#import "/.calepin/calepin.typ" as calepin

#set document(title: [Executable code])
#metadata((title: "Executable code")) <website-metadata>

#title()

Mosaic has no code-execution feature of its own: a `.typ` deck is plain Typst, and Typst does not run code blocks. To put a live analysis, a generated figure, or a computed number on a slide, run it with #link("https://vincentarelbundock.github.io/calepin/")[Calepin], a computational notebook for Typst that executes R (and other languages) at compile time and hands the results back as Typst content.

A chunk in an ordinary Mosaic deck, once `calepin.setup` has run:

````typ
== A generated figure

#calepin.chunk("r", echo: true, results: "render")[
```r
library(ggplot2)
ggplot(mtcars, aes(hp, mpg)) +
  geom_point() +
  geom_smooth(method = "lm")
```
]
````

The chunk compiles as ordinary content inside the slide, so Mosaic's layouts, cells, and reveal steps apply to it exactly as they would to any other block. See Calepin's #link("https://vincentarelbundock.github.io/calepin/getting-started/install.html")[installation instructions] to get started.

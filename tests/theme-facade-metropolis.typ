#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.metropolis as m

#let expected = (
  "setup", "slide", "grid", "layouts", "steps", "components",
)

#assert(expected.all(name => name in m))
#assert(("cell", "h", "t", "v").all(name => name in m.grid))
#assert(("author", "default", "section", "title").all(name => name in m.layouts))
#assert(("on", "reduce", "replace", "reveal").all(name => name in m.steps))
#assert((
  "callout", "divider", "frame", "image", "label", "progress", "quote",
).all(name => name in m.components))
#assert(type(m.layouts.default()) == dictionary)
#assert(type(m.layouts.title([No-author title])) == dictionary)
#assert(type(m.layouts.section(subtitle: [Subtitle])) == dictionary)

#show: m.setup

#m.slide(grid: m.layouts.title([No-author title]), numbered: false)

#m.slide(
  grid: m.layouts.default(),
  content: (header: [Explicit header], body: [Explicit body]),
)

= Automatic section

== Automatic ordinary slide

Automatic body.

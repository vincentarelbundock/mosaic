#import "@local/mosaic:0.0.2" as mosaic
#import mosaic.themes.metropolis as m

#let expected = (
  "setup", "slide", "grids", "layouts", "steps", "components",
)

#assert(expected.all(name => name in m))
#assert(("cell", "columns", "rows", "track").all(name => name in m.grids))
#assert(("author", "content", "section", "title").all(name => name in m.layouts))
#assert(("drawing", "on", "replace", "reveal").all(name => name in m.steps))
#assert((
  "badge", "callout", "card", "divider", "figure", "image",
  "progress", "quote",
).all(name => name in m.components))
#assert(type(m.layouts.content()) == dictionary)
#assert(type(m.layouts.title(title: [No-author title])) == dictionary)
#assert(type(m.layouts.section(subtitle: [Subtitle])) == dictionary)

#show: m.setup

#m.slide(layout: m.layouts.title(title: [No-author title]), numbered: false)

#m.slide(
  layout: m.layouts.content(),
  cells: (header: [Explicit header], body: [Explicit body]),
)

= Automatic section

== Automatic ordinary slide

Automatic body.

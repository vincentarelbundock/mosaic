#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.metropolis as m

#let expected = (
  "setup", "slide", "pause", "grids", "layouts", "steps", "components",
)

#assert(expected.all(name => name in m))
#assert(("cell", "h", "t", "v").all(name => name in m.grids))
#assert(("author", "content", "section", "title").all(name => name in m.layouts))
#assert(("on", "reduce", "replace", "reveal").all(name => name in m.steps))
#assert((
  "callout", "divider", "figure", "frame", "image", "progress",
  "quote", "tag",
).all(name => name in m.components))
#assert(type(m.layouts.content()) == dictionary)
#assert(type(m.layouts.title(title: [No-author title])) == dictionary)
#assert(type(m.layouts.section(subtitle: [Subtitle])) == dictionary)

#show: m.setup

#m.slide(layout: m.layouts.title(title: [No-author title]), numbered: false)

#m.slide(
  layout: m.layouts.content(),
  content: (header: [Explicit header], body: [Explicit body]),
)

= Automatic section

== Automatic ordinary slide

Automatic body.

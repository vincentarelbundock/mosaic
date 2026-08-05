#import "@local/mosaic:0.0.1" as m

#let expected = (
  "setup", "slide", "note", "fit", "surface", "grids", "layouts", "steps", "components", "themes",
)

#assert(expected.all(name => name in m))
#assert(("cell", "columns", "rows", "track").all(name => name in m.grids))
#assert(("author", "content", "section", "title").all(name => name in m.layouts))
#assert(("drawing", "on", "replace", "reveal").all(name => name in m.steps))
#assert((
  "badge", "callout", "card", "divider", "image", "progress", "quote",
).all(name => name in m.components))
#assert(("default", "editorial", "manifesto", "metropolis", "mono").all(name => name in m.themes))

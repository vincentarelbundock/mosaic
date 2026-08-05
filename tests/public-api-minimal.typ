#import "@local/mosaic:0.0.1" as m

#let expected = (
  "setup", "slide", "note", "fit", "surface", "grids", "layouts", "steps", "components", "themes",
)

#assert(expected.all(name => name in m))
#assert(("cell", "h", "t", "v").all(name => name in m.grids))
#assert(("author", "content", "section", "title").all(name => name in m.layouts))
#assert(("on", "reduce", "replace", "reveal").all(name => name in m.steps))
#assert((
  "callout", "divider", "frame", "image", "progress", "quote", "tag",
).all(name => name in m.components))
#assert(("cream", "metropolis", "minimalist").all(name => name in m.themes))

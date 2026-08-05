#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.cream as cream
#import mosaic.themes.dark as dark
#import mosaic.themes.light as light
#import mosaic.themes.minimalist as minimalist

#let expected = (
  "setup", "slide", "note", "surface", "grids", "layouts", "steps", "components",
)

#for theme in (cream, dark, light, minimalist) {
  assert(expected.all(name => name in theme))
  assert(("cell", "columns", "rows", "track").all(name => name in theme.grids))
  assert(("author", "content", "section", "title").all(name => name in theme.layouts))
  assert(("drawing", "on", "pause", "replace", "reveal").all(name => name in theme.steps))
  assert((
    "badge", "callout", "card", "divider", "figure", "image",
    "progress", "quote",
  ).all(name => name in theme.components))
  assert(type(theme.layouts.content()) == dictionary)
  assert(type(theme.layouts.title(title: [No-author title])) == dictionary)
  assert(type(theme.layouts.section()) == dictionary)
}

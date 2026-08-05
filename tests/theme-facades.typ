#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.cream as cream
#import mosaic.themes.dark as dark
#import mosaic.themes.light as light
#import mosaic.themes.minimalist as minimalist

#let expected = (
  "setup", "slide", "note", "pause", "surface", "grid", "layouts", "steps", "components",
)

#for theme in (cream, dark, light, minimalist) {
  assert(expected.all(name => name in theme))
  assert(("cell", "h", "t", "v").all(name => name in theme.grid))
  assert(("author", "content", "section", "title").all(name => name in theme.layouts))
  assert(("on", "reduce", "replace", "reveal").all(name => name in theme.steps))
  assert((
    "callout", "divider", "figure", "frame", "image", "label", "progress",
    "quote",
  ).all(name => name in theme.components))
  assert(type(theme.layouts.content()) == dictionary)
  assert(type(theme.layouts.title(title: [No-author title])) == dictionary)
  assert(type(theme.layouts.section()) == dictionary)
}

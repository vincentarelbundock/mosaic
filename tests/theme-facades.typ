#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.cream as cream
#import mosaic.themes.minimalist as minimalist

#let expected = (
  "setup", "slide", "note", "surface", "grid", "layouts", "steps", "components",
)

#for theme in (cream, minimalist) {
  assert(expected.all(name => name in theme))
  assert(("cell", "h", "t", "v").all(name => name in theme.grid))
  assert(("author", "default", "section", "title").all(name => name in theme.layouts))
  assert(("on", "reduce", "replace", "reveal").all(name => name in theme.steps))
  assert((
    "callout", "divider", "frame", "image", "label", "progress", "quote",
  ).all(name => name in theme.components))
  assert(type(theme.layouts.default()) == dictionary)
  assert(type(theme.layouts.title([No-author title])) == dictionary)
  assert(type(theme.layouts.section()) == dictionary)
}

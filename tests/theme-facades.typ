#import "@local/mosaic:0.0.2" as mosaic
#import mosaic.themes.editorial as editorial
#import mosaic.themes.default as default-theme
#import mosaic.themes.metropolis as metropolis
#import mosaic.themes.manifesto as manifesto
#import mosaic.themes.mono as mono

#let expected = (
  "setup", "slide", "note", "surface", "grids", "layouts", "steps", "components",
)

#for theme in (default-theme, editorial, manifesto, metropolis, mono) {
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

#import "../mosaic/src/settings.typ": make-settings, validate-settings

#let settings = make-settings()
#assert(settings.keys().sorted() == (
  "colors", "content", "deck", "overflow", "shape", "spacing", "type",
))
#assert(settings.content == (:))
#let with-content = make-settings(content: (
  footer: "Footer",
  background: "Background",
  foreground: [Foreground],
  empty: none,
))
#assert(type(with-content.content.footer) == content)
#assert(with-content.content.footer == [Footer])
#assert(with-content.content.background == [Background])
#assert(with-content.content.foreground == [Foreground])
#assert(with-content.content.empty == none)
#assert(settings.deck == (title: none, subtitle: none, authors: (), date: none))
#assert(settings.colors.keys().sorted() == (
  "accent", "canvas", "line", "muted", "surface", "text",
))
#assert(settings.colors.values().all(value => type(value) == color))
#assert(settings.overflow == "warn")
#assert(make-settings(overflow: "off").overflow == "off")
#assert(validate-settings(settings) == settings)
